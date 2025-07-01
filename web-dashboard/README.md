# Fluxo Web Dashboard

A modern web dashboard for managing Fluxo plugin projects, tracking versions, and monitoring publishing activity.

## Features

- **Plugin Management**: Track all your plugin projects in one place
- **Version History**: See complete version history and changelogs
- **Publishing Analytics**: Monitor publishing activity and performance
- **Team Collaboration**: Manage team access and permissions
- **CI/CD Integration**: Connect with GitHub Actions and other CI/CD tools

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
npm start
```

## Environment Variables

Create a `.env.local` file:

```
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key
DATABASE_URL=your-database-url
ROBLOX_API_KEY=your-roblox-api-key
```

## Tech Stack

- **Framework**: Next.js 14
- **Styling**: Tailwind CSS
- **Icons**: Heroicons
- **Charts**: Recharts
- **Authentication**: NextAuth.js (planned)
- **Database**: PostgreSQL (planned)

## Pages

- `/` - Dashboard overview
- `/plugins` - Plugin management
- `/plugins/[id]` - Plugin details and settings
- `/analytics` - Publishing analytics
- `/team` - Team management
- `/settings` - Account settings

This dashboard complements the CLI tool and Studio plugin, providing a centralized place for plugin project management and team collaboration.
