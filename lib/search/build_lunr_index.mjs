import lunr from 'lunr';
import fs from 'fs';

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

// Write serialized index to public directory
fs.writeFileSync('public/lunr-index.json', JSON.stringify(serializedIndex));

// Write documents to public directory (needed for displaying results)
fs.writeFileSync('public/search-documents.json', JSON.stringify(documents));

console.log('✓ Lunr index serialized to public/lunr-index.json');
console.log('✓ Documents saved to public/search-documents.json');

const indexSize = (JSON.stringify(serializedIndex).length / 1024).toFixed(2);
const docsSize = (JSON.stringify(documents).length / 1024).toFixed(2);

console.log(`Index size: ${indexSize}KB`);
console.log(`Documents size: ${docsSize}KB`);
