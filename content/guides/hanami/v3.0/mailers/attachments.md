---
title: Attachments
---

Mailers can attach files to the emails they send. Attachments can be static files loaded from disk, computed dynamically from your input, embedded inline in the HTML body, or passed in at delivery time.

## Static attachments

Attach a file by name with `attachment`. The file is loaded from the paths configured in `config.attachment_paths`:

```ruby
class WelcomePackMailer < Bookshelf::Mailer
  from "welcome@bookshelf.test"
  to { |user:| user[:email] }
  subject "Your welcome pack"

  config.attachment_paths = ["attachments"]

  attachment "terms.pdf"
  attachment "getting-started-guide.pdf"
end
```

Attachment paths are resolved relative to your project root, and hold static files rather than Ruby source, so keep them outside `app/`.

If a file can't be found in any configured path, a `MissingAttachmentError` is raised.

## Dynamic attachments

To compute an attachment from your input or exposures, give `attachment` a block. Use the `file` helper to build the attachment, and follow the usual [parameter rule](//page/exposures-and-input#the-block-parameter-rule):

```ruby
class ReportMailer < Bookshelf::Mailer
  from "reports@bookshelf.test"
  to { |user:| user[:email] }
  subject "Your monthly report"

  expose :user

  attachment do |user:|
    file(
      "report-#{user[:id]}.pdf",
      generate_report_pdf(user),
      content_type: "application/pdf"
    )
  end

  private

  def generate_report_pdf(user)
    # ... generate PDF content
  end
end
```

The `file` helper takes these arguments:

- `filename` — the name the recipient sees.
- `content` — the file's data, as a string or IO.
- `content_type:` — the MIME type. When omitted, it's inferred from the filename's extension, falling back to `application/octet-stream`.
- `inline:` — whether to embed the attachment in the HTML body (defaults to `false`). See [Inline attachments](#inline-attachments).

An attachment block can return several attachments at once:

```ruby
attachment do |documents:|
  documents.map { |doc| file(doc[:name], doc[:content]) }
end
```

You can also name an instance method instead of passing a block:

```ruby
class InvoiceMailer < Bookshelf::Mailer
  from "billing@bookshelf.test"
  to { |customer:| customer[:email] }
  subject "Your invoice"

  expose :invoice

  attachment :invoice_pdf

  private

  def invoice_pdf(invoice:)
    file(
      "invoice-#{invoice[:number]}.pdf",
      generate_pdf(invoice),
      content_type: "application/pdf"
    )
  end
end
```

## Inline attachments

Inline attachments embed images directly in your HTML body. The Content-ID is derived from the filename, so you reference it in the template with `cid:filename`:

```ruby
class NewsletterMailer < Bookshelf::Mailer
  from "news@bookshelf.test"
  to { |subscriber:| subscriber[:email] }
  subject "This week at Bookshelf"

  attachment do
    file("header.png", header_image_data, inline: true)
  end

  private

  def header_image_data
    File.read("app/assets/images/newsletter-header.png")
  end
end
```

```html
<img src="cid:header.png" alt="Newsletter header" />
```

A static attachment can be made inline too:

```ruby
attachment "logo.png", inline: true
```

## Runtime attachments

Add attachments at delivery time, without declaring them on the mailer. This suits one-off or conditional attachments, or pre-generated files passed in from the calling code. Pass them as an array of `attachments:` hashes:

```ruby
order_mailer.deliver(
  customer: {email: "customer@example.com"},
  attachments: [
    {filename: "invoice-123.pdf", content: pdf_bytes},
    {filename: "receipt.txt", content: "Thank you!"}
  ]
)
```

Runtime attachments are included alongside any the mailer declares itself. You can also build them with the `Hanami::Mailer.file` helper:

```ruby
order_mailer.deliver(
  customer: {email: "customer@example.com"},
  attachments: [
    Hanami::Mailer.file("invoice-123.pdf", pdf_bytes, content_type: "application/pdf")
  ]
)
```
