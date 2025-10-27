# Cosmique Website

A minimalist static website for Cosmique, inspired by Dieter Rams' design principles and 1970s Braun aesthetics.

## Features

- Built with [Eleventy (11ty)](https://www.11ty.dev/) - a simple, powerful static site generator
- Content managed via `content.json` - easily update apps and site information
- Clean, minimal design inspired by Dieter Rams and Braun radios
- Automatic deployment to GitHub Pages
- Fully responsive design

## Local Development

1. Install dependencies:
   ```bash
   cd website
   npm install
   ```

2. Start the development server:
   ```bash
   npm start
   ```

3. Open your browser to `http://localhost:8080`

## Updating Content

Edit `content.json` to update your apps and site information:

```json
{
  "site": {
    "title": "Cosmique",
    "description": "Solo App Development",
    "url": "https://yourusername.github.io/cosmique"
  },
  "apps": [
    {
      "name": "app name",
      "description": "app description",
      "slug": "app-slug"
    }
  ]
}
```

## Building for Production

```bash
npm run build
```

The built site will be in the `_site` directory.

## Deployment to GitHub Pages

The site is automatically deployed to GitHub Pages when you push to the main branch.

**Live URL:** https://cosmique-source.github.io/cosmique-website/

### Pushing Changes

Since this repo uses a specific SSH key, use one of these methods:

**Option 1: Use the SSH key each time**
```bash
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_cosmique -o IdentitiesOnly=yes' git push
```

**Option 2: Configure it once for this repo (recommended)**
```bash
git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_cosmique -o IdentitiesOnly=yes"
# Then just use: git push
```

### Manual Setup (if needed)

1. Push your code to GitHub
2. Go to your repository Settings > Pages
3. Under "Build and deployment", select "GitHub Actions" as the source
4. The site will automatically deploy when you push to the main branch

## Design Philosophy

This site follows Dieter Rams' ten principles of good design:
- Good design is innovative
- Good design makes a product useful
- Good design is aesthetic
- Good design is unobtrusive
- Good design is honest
- Good design is long-lasting
- Good design is thorough down to the last detail
- Good design is environmentally friendly
- Good design is as little design as possible

The visual language draws from 1970s Braun products: clean lines, functional typography (Helvetica/Akzidenz-Grotesk inspired), restrained color palette, and focus on clarity.
