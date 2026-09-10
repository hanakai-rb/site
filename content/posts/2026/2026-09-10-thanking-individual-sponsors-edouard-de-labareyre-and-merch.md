---
title: Thanking our individual sponsors, Edouard de Labareyre, and a merch announcement
date: 2026-09-10 11:45:00 UTC
author: Tim Riley
excerpt: >
  “I was hooked, my choice was made.” Week four of our sponsorship drive.
---

Welcome to week four of our [2026 sponsorship drive](/blog/2026/08/11/sponsor-hanakai-in-2026)! (Don't forget to catch up on weeks [one](/blog/2026/08/11/sponsor-hanakai-in-2026), [two](/blog/2026/08/19/power-in-numbers-and-pat-allan) and [three](/blog/2026/09/02/thanking-our-silver-sponsors-and-carolyn-cole)).

This will be our last post before we come back one last time to wrap things up. We do have some treats for you this week, though: a wonderful Q&A with long-time Hanami developer Edouard de Labareyre, a gaggle of individual sponsors to thank, and some news about merch!

## Q&A with Edouard de Labareyre

<img src="/blog/assets/2026-09-10-thanking-individual-sponsors-edouard-de-labareyre-and-merch/edouard.webp" alt="Edouard de Labareyre" title="Edouard de Labareyre" class="float-image float-image--end">

We're wrapping up our Q&As with a great one, featuring [Edouard de Labareyre](https://github.com/inouire)!

Edouard is a true stalwart of the Hanakai community, shipping Hanami to production since version 1.1. Edouard truly gets what we're about, and we in the community are lucky to benefit from his generosity, whether through his [long-running thread of Hanami upgrade tips](https://discourse.hanakai.org/t/hanami-1-3-hanami-2-2-tips-notes-about-my-journey/1210/33) or his [several](https://github.com/hanami/hanami-router/pull/304) [improvements](https://github.com/hanami/hanami-router/pull/282) to our gems. Thank you Edouard!

**Who are you, and what are you building?**

My name is Edouard, I'm a french software engineer. I live in Versailles, near Paris. I've been working in computer science since 2008, and today I'm the CTO of [PPE analytics](https://www.ppe-analytics.com), the company I founded 10 years ago with a friend. We are developing a PIM software in the field of Personal Protective Equipments (PPE) Throughout my carrier I've been coding in Java, PHP and Ruby.

**What made you reach for Hanakai, and what does your stack look like today?**

I've been an Hanami user since v1.1 when Luca was building it. I was launching my business at the time and I was looking for a Ruby stack I felt in control with. I loved Ruby and Sequel, but Rails did not suit me. I looked around and found Hanami's website. I could not resist immediately reading the whole documentation: I was hooked, my choice was made.

I started building happily with Hanami and Sequel. Being able to understand and adapt my stack has been decisive to bootstrap our business. We've followed the versions bumps throughout the years, and more recently I was very happy to see what Hanami 2 was promising: more mature, more compact, but still with this great level of control over what's done under the hood.

We launched a spin-off project last year with Hanami 2 ([Catalogue Studio](https://catalogue-studio.com), you can check it out it's open and free). It was a great way to acquire new habits and getting confortable with the new concepts. We're currently in the process of migrating our legacy stack, which is quite heavy: ETA end of this year ([I've taken notes along the way](https://discourse.hanakai.org/t/hanami-1-3-hanami-2-2-tips-notes-about-my-journey/1210/33)).

Our stack is now a Hanami 2 app, with 5 slices made to be launched separately. Service objects are mostly Hanami interactors, legacy of our Hanami 1 years. We're running on a PostgreSQL database, that we access through Sequel gem. We have a Redis connection for sessions too. And an S3 compatible object storage for file storage. We integrate HTMX and Alpine.js for the frontend when we need dynamic behaviors.

**What's a moment building with Hanakai that made you think, "yes, this is why"?**

I like to keep things simple, and try to avoid having too many moving parts and dependencies. My goal is to be able to be at peace while I build things in the long run (we're a small team).

I realized it when I first read Hanami's documentation, and I still regularly do: Hanakai is the perfect framework for us. It empowers us, by giving us great tools and patterns, but it never forces us. We can step out on some topics, adopt some others, and even change over time.

Hanakai is not my code, but I can still feel that I own the projects I build with it. So thank you Luca, Tim & all the contributors for this great piece of software, I'm so happy to be able to use it everyday.

**What are you excited about for the future?**

Right now I mostly want us to finish my Hanami 1 to Hanami 2+ migration! ;) When it'll be over, I'm excited to see how the team velocity will evolve. I feel that we'll be able to imagine/build/try/refactor things even better and faster, and with even more fun which is very important to me.

I also plan to explore more deeply the concepts that Hanakai offers: I especially love the ideas around Dry containers & Dry Operation, it really speaks to me and I can't wait to understand and use them more in the future.

---

_Thank you Edouard for sharing with us today!_

## Thank you to our individual sponsors!

This week is our chance to celebrate our individual sponsors! Out of the goodness of their own hearts (and wallets!), these folks are making it possible for us to continue our work maintaining and improving all of Hanakai.

Let me start by thanking those of you who've been with us for the last year or more. That's [@aaronmallen](https://github.com/aaronmallen), [@afomera](https://github.com/afomera), [@caius](https://github.com/caius), [@CG3-Media](https://github.com/CG3-Media), [@danhealy](https://github.com/danhealy), [@hedselu](https://github.com/hedselu), [@jaredsmithse](https://github.com/jaredsmithse), [@josephinehall](https://github.com/josephinehall), [@mathewdbutton](https://github.com/mathewdbutton), [@practical-computer](https://github.com/practical-computer), [@rosa](https://github.com/rosa), [@schlick](https://github.com/schlick), [@tombruijn](https://github.com/tombruijn), [@whysthatso](https://github.com/whysthatso), plus one private sponsor. **Thank you for believing in us!**

And now for the folks that joined us as part of this year's sponsorship drive:
[@andrew](https://github.com/andrew), [Atelier Mirai](https://opencollective.com/atelier-mirai), [Ben Sheldon](https://opencollective.com/bensheldon), [@bensinc](https://github.com/bensinc), [@ChaelCodes](https://github.com/ChaelCodes), [@dalmaboros](https://github.com/dalmaboros), [@JackBracken](https://github.com/JackBracken), James Adney, [@skyfallwastaken](https://github.com/skyfallwastaken), [Sangwon Yi](https://opencollective.com/yisangwon), [Tracy Hall](https://opencollective.com/tracy-hall), [@zzulu](https://github.com/zzulu), plus two more private sponsors. **Thank you for coming on board!**

That's 29 of you, with 14 of you joining as part of this drive. You are true difference-makers for Ruby! Your support goes a long way towards making our ongoing maintenance of Hanakai viable.

You too can become part of this esteemed group! It's easy to do, and we'll love you forever. Go check out [our sponsorship page](/sponsor) for the deets.

## Merch is coming! (And sponsors get a treat)

One more thing.

It's been a few months since we [launched Hanakai](/blog/2026/05/01/welcome-to-hanakai) and our beautiful new branding. Now we're going to give these logos what they deserve: a merch store!

![A preview of Hanakai merch](/blog/assets/2026-09-10-thanking-individual-sponsors-edouard-de-labareyre-and-merch/hanakai-merch.webp "A preview of Hanakai merch")

We're just beginning the planning for this, but I already know that our designers [Aaron](https://github.com/aaronmoodie) and [Max](https://github.com/makenosound) are going to put together something delightful.

As part of this, we want to offer a treat to all our sponsors: if you support Hanakai at $25/mo for 12 months, **you'll receive a free piece of exclusive sponsor merch!** We'll count every sponsorship dating back to the start of this year. This is a small token of our gratitude to you, and we hope to make it really special.

Make sure to follow our site or socials (or join our [community spaces](/community)) to be the first to know when we launch!

## See you next week

We'll be back once more to wrap up our sponsorship drive for 2026. Until then, there's still time to [share our posts](/blog/2026/08/11/sponsor-hanakai-in-2026) and [come on board as a sponsor](/sponsor). We're a small operation, so every bit of help really makes a difference.
