# QRs'R'Fun

A Jekyll-based static website that generates individual pages for wedding guests from a CSV file.

## Setup

1. Install Jekyll and dependencies:
```bash
bundle install
```

2. Update the `contents.csv` file with your guest information

3. Build and serve locally:
```bash
bundle exec jekyll serve
```

4. Guest pages will be available at URLs like:
   - `/john-smith.html`
   - `/sarah-johnson.html`
   - etc.

## CSV Format

The `contents.csv` file should have the following columns:
- NAME: Guest's full name
- CONNECTION: How they're connected to the couple
- INTERESTS: Their interests and talking points
- MEET_OTHERS: Other guests they should meet

## Deployment

This site is configured for GitHub Pages deployment. Simply push to your repository and enable GitHub Pages in the repository settings.

## Generated URLs

Each guest page URL is generated from their NAME field:
- Spaces are replaced with hyphens
- Names are converted to lowercase
- Example: "John Smith" → `/john-smith.html`