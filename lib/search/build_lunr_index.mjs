import lunr from 'lunr';
import fs from 'fs';
import crypto from 'crypto';

console.log('Building Lunr.js search index...');

// Read documents from temporary file
const documents = JSON.parse(fs.readFileSync('tmp/search-documents.json', 'utf-8'));

console.log(`Processing ${documents.length} documents...`);

// Build Lunr index
const index = lunr(function () {
  this.ref('id');

  // Configure fields with boost values
  this.field('title', { boost: 10 });
  this.field('titleBoost', { boost: 15 }); // Extra boost for latest versions
  this.field('headings', { boost: 5 });
  this.field('content');
  this.field('section', { boost: 3 });
  this.field('subsection', { boost: 3 });

  // Add each document to the index
  documents.forEach((doc) => {
    this.add({
      id: doc.id,
      title: doc.title,
      // Duplicate title for latest versions to boost their ranking
      titleBoost: doc.isLatest ? doc.title : '',
      headings: doc.headings.join(' '),
      content: doc.content,
      section: doc.section,
      subsection: doc.subsection,
    });
  });
});

// Serialize the index
const serializedIndex = index.toJSON();

// Generate checksum for cache busting
const docsContent = JSON.stringify(documents);
const indexContent = JSON.stringify(serializedIndex);
const checksum = crypto.createHash('md5').update(docsContent).digest('hex').substring(0, 8);

// Write files with checksum in filename
fs.writeFileSync(`public/lunr-index.${checksum}.json`, indexContent);
fs.writeFileSync(`public/search-documents.${checksum}.json`, docsContent);

// Write a manifest file with the current checksum
fs.writeFileSync('public/search-manifest.json', JSON.stringify({ checksum }));

console.log(`✓ Lunr index serialized to public/lunr-index.${checksum}.json`);
console.log(`✓ Documents saved to public/search-documents.${checksum}.json`);
console.log(`✓ Checksum: ${checksum}`);

const indexSize = (JSON.stringify(serializedIndex).length / 1024).toFixed(2);
const docsSize = (docsContent.length / 1024).toFixed(2);

console.log(`Index size: ${indexSize}KB`);
console.log(`Documents size: ${docsSize}KB`);
