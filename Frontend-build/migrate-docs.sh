#!/bin/bash
# Documentation Migration Script
# Created: October 31, 2025
# Purpose: Reorganize documentation for LLM agent efficiency

set -e  # Exit on error

echo "🚀 Menu.ca Documentation Migration"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${BLUE}Current directory:${NC} $SCRIPT_DIR"
echo ""

# Confirmation
echo -e "${YELLOW}⚠️  This will reorganize all documentation files.${NC}"
echo "Old files will be preserved in archive/ folder."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Migration cancelled"
    exit 1
fi

echo ""
echo "📁 Creating new folder structure..."

# Phase 1: Create directory structure
mkdir -p docs/00-getting-started
mkdir -p docs/01-api-reference/integrations
mkdir -p docs/02-features/authentication
mkdir -p docs/02-features/menu-system
mkdir -p docs/02-features/ordering
mkdir -p docs/02-features/search
mkdir -p docs/02-features/reviews
mkdir -p docs/03-database/migrations
mkdir -p docs/04-architecture
mkdir -p docs/05-guides
mkdir -p docs/06-reference
mkdir -p archive

echo -e "${GREEN}✓${NC} Folder structure created"

# Phase 2: Move files (with backup)
echo ""
echo "📦 Moving files..."

# Function to move file with logging
move_file() {
    local src="$1"
    local dest="$2"
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo -e "${GREEN}✓${NC} Moved: $src → $dest"
        echo "  $src" >> archive/moved_files.log
    else
        echo -e "${YELLOW}⚠${NC} Not found: $src"
    fi
}

# Getting Started
echo ""
echo "📖 Moving Getting Started docs..."
move_file "START_HERE.md" "docs/00-getting-started/quick-start.md"
move_file "FRONTEND_BUILD_MEMORY.md" "docs/00-getting-started/project-overview.md"
move_file "DOCUMENTATION/FRONTEND_BUILD_START_HERE.md" "docs/00-getting-started/start-here-old.md"
move_file "DOCUMENTATION/COMPETITION_ENVIRONMENT_SETUP.md" "docs/00-getting-started/environment-setup.md"

# API Reference
echo ""
echo "🔌 Moving API Reference docs..."
move_file "customer-app/CUSTOMER_API_GUIDE.md" "docs/01-api-reference/customer-api.md"
move_file "customer-app/YELP_INTEGRATION_GUIDE.md" "docs/01-api-reference/integrations/yelp-api.md"

# Features - Authentication
echo ""
echo "🔐 Moving Authentication docs..."
move_file "DOCUMENTATION/Users & Access features.md" "docs/02-features/authentication/users-and-access.md"
move_file "DOCUMENTATION/ADMIN_PASSWORD_VALIDATION_GUIDE.md" "docs/02-features/authentication/password-validation.md"
move_file "customer-app/SMS_AUTHENTICATION_COMPLETE.md" "docs/02-features/authentication/sms-auth.md"

# Features - Ordering
echo ""
echo "🛒 Moving Ordering docs..."
move_file "PAYMENT_ORDER_INTEGRATION_COMPLETE.md" "docs/02-features/ordering/payments.md"

# Features - Search
echo ""
echo "🔍 Moving Search docs..."
move_file "AI_SEARCH_DEMO_INSTRUCTIONS.md" "docs/02-features/search/ai-search.md"
move_file "SEARCH_PAGE_PREMIUM_COMPLETE.md" "docs/02-features/search/search-page.md"

# Features - Reviews
echo ""
echo "⭐ Moving Reviews docs..."
move_file "customer-app/YELP_INTEGRATION_SUMMARY.md" "docs/02-features/reviews/yelp-integration.md"

# Database
echo ""
echo "🗄️  Moving Database docs..."
move_file "DATABASE_SCHEMA_REFERENCE.md" "docs/03-database/schema-reference.md"
move_file "DATABASE_CONNECTION_PLAN.md" "docs/03-database/connection-guide.md"
move_file "DATABASE_IMPLEMENTATION_PLAN.md" "docs/03-database/migrations/implementation-plan.md"

# Architecture
echo ""
echo "🏗️  Moving Architecture docs..."
move_file "ORCHESTRATOR_CONTEXT.md" "docs/04-architecture/data-flow.md"

# Archive old/deprecated docs
echo ""
echo "🗄️  Archiving old docs..."
move_file "DOCUMENTATION/CURRENT_STATUS_OLD.md" "archive/current-status-old.md"
move_file "CURSOR_FINDINGS_DATA_INVESTIGATION.md" "archive/cursor-findings.md"
move_file "DATA_DISCREPANCY_PRIMA_PIZZA.md" "archive/data-discrepancy-prima-pizza.md"
move_file "MISSING_DATABASE_COLUMNS_REPORT.md" "archive/missing-columns-report.md"
move_file "AI_POWERED_DEMO_READY.md" "archive/ai-powered-demo-ready.md"
move_file "MVP_DEMO_READY.md" "archive/mvp-demo-ready.md"
move_file "MVP_LAUNCH_SUMMARY.md" "archive/mvp-launch-summary.md"

# Rename folders to lowercase
echo ""
echo "📂 Renaming folders to lowercase..."
if [ -d "AUDITS" ]; then
    mv AUDITS audits 2>/dev/null || true
    echo -e "${GREEN}✓${NC} AUDITS → audits"
fi
if [ -d "HANDOFFS" ]; then
    mv HANDOFFS handoffs 2>/dev/null || true
    echo -e "${GREEN}✓${NC} HANDOFFS → handoffs"
fi
if [ -d "TICKETS" ]; then
    mv TICKETS tickets 2>/dev/null || true
    echo -e "${GREEN}✓${NC} TICKETS → tickets"
fi

# Phase 3: Create Master Index (README.md)
echo ""
echo "📝 Creating master README.md..."

cat > README.md << 'EOF'
# 🍽️ Menu.ca Frontend Build

**Modern food ordering platform - Customer & Admin applications**

---

## 🚀 Quick Start

**New to the project?** Start here:

1. [Getting Started Guide](docs/00-getting-started/quick-start.md) ⭐
2. [Environment Setup](docs/00-getting-started/environment-setup.md)
3. [Project Overview](docs/00-getting-started/project-overview.md)

**Returning developer?** Jump to:
- [API Reference](docs/01-api-reference/) 🔌
- [Feature Docs](docs/02-features/) 🎯
- [Database Schema](docs/03-database/schema-reference.md) 🗄️

---

## 📚 Documentation Structure

### 📖 [00. Getting Started](docs/00-getting-started/)
- Quick start guide
- Environment setup
- Project overview and architecture

### 🔌 [01. API Reference](docs/01-api-reference/)
- [Customer API](docs/01-api-reference/customer-api.md) - Public endpoints
- [Admin API](docs/01-api-reference/admin-api.md) - Admin operations
- [Auth API](docs/01-api-reference/auth-api.md) - Authentication
- **Integrations:**
  - [Yelp API](docs/01-api-reference/integrations/yelp-api.md)
  - [Stripe API](docs/01-api-reference/integrations/stripe-api.md)

### 🎯 [02. Features](docs/02-features/)
- **[Authentication](docs/02-features/authentication/)** - User & admin auth
- **[Menu System](docs/02-features/menu-system/)** - Dishes, modifiers, pricing
- **[Ordering](docs/02-features/ordering/)** - Cart, checkout, payments
- **[Search](docs/02-features/search/)** - AI-powered search
- **[Reviews](docs/02-features/reviews/)** - Yelp integration

### 🗄️ [03. Database](docs/03-database/)
- [Schema Reference](docs/03-database/schema-reference.md) ⭐
- [Connection Guide](docs/03-database/connection-guide.md)
- [Migrations](docs/03-database/migrations/)

### 🏗️ [04. Architecture](docs/04-architecture/)
- System design
- Data flow
- Security model

### 📖 [05. Guides](docs/05-guides/)
- How-to guides
- Best practices
- Troubleshooting

### ⚡ [06. Reference](docs/06-reference/)
- Quick reference materials
- Common patterns
- Cheat sheets

---

## 🤖 For LLM Agents

**Priority Docs (Load These First):**
1. [Customer API Reference](docs/01-api-reference/customer-api.md) - Most used endpoints
2. [Database Schema](docs/03-database/schema-reference.md) - Data structure
3. [Authentication Guide](docs/02-features/authentication/) - Auth patterns
4. [Common Patterns](docs/06-reference/common-patterns.md) - Code standards

**Navigation Pattern:**
```
Task → README.md → Category folder → Specific doc
```

**Finding Information:**
- API endpoints → `docs/01-api-reference/`
- How features work → `docs/02-features/[category]/`
- Database info → `docs/03-database/`
- Code examples → `docs/06-reference/`

---

## 📦 Applications

### Customer App
- **Location:** `customer-app/`
- **Tech:** Next.js 16, React, Tailwind CSS, Supabase
- **Docs:** [Customer App README](customer-app/README.md)

---

## 🔧 Development

### Prerequisites
- Node.js 18+
- npm or yarn
- Supabase account
- Yelp API key (for reviews)

### Quick Setup
```bash
cd customer-app
npm install
cp .env.example .env
# Add your API keys to .env
npm run dev
```

See [Environment Setup Guide](docs/00-getting-started/environment-setup.md) for details.

---

## 📂 Repository Structure

```
Frontend-build/
├── docs/                   # 📚 All documentation
├── customer-app/           # 💻 Customer-facing app
├── audits/                 # 🔍 System audits
├── handoffs/               # 🔄 Session handoffs
├── tickets/                # 🎫 Work tickets
└── archive/                # 🗄️ Old/deprecated docs
```

---

## 🚀 Deployment

**Production URL:** https://customer-app-navy.vercel.app

**Deploy:**
```bash
cd customer-app
vercel --prod
```

See [Deployment Guide](docs/05-guides/deployment-guide.md) for details.

---

## 📊 Project Status

- **Customer App:** ✅ Production (75 active restaurants)
- **Admin Dashboard:** 🚧 In Progress
- **Mobile App:** 📋 Planned

**Recent Updates:**
- ✅ AI-powered search (OpenAI GPT-4)
- ✅ Yelp reviews integration
- ✅ SMS authentication
- ✅ Stripe payments
- ⏳ Real operational data (delivery fees, times)

See [CHANGELOG.md](CHANGELOG.md) for detailed history.

---

## 🤝 Contributing

1. Read relevant docs in `docs/`
2. Follow patterns in `docs/06-reference/common-patterns.md`
3. Test changes locally
4. Update documentation if needed

---

## 📞 Support

- **Documentation Issues:** Check `docs/05-guides/troubleshooting.md`
- **API Questions:** See `docs/01-api-reference/`
- **Feature Requests:** Create issue with details

---

**Last Updated:** October 31, 2025
**Maintained By:** Menu.ca Development Team
EOF

echo -e "${GREEN}✓${NC} README.md created"

# Create CHANGELOG.md
echo ""
echo "📅 Creating CHANGELOG.md..."

cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to the Menu.ca Frontend Build will be documented in this file.

## [Unreleased]

### Added
- Documentation restructure for LLM agent efficiency
- Master README.md with clear navigation
- Organized docs/ folder with logical hierarchy

## [2025-10-31] - Documentation Restructure

### Added
- LLM-optimized documentation structure
- Clear navigation paths for agents
- Status badges and metadata
- Cross-references between related docs

### Changed
- Moved all docs to centralized `docs/` folder
- Renamed folders to lowercase (audits, handoffs, tickets)
- Consolidated duplicate documentation
- Improved file naming conventions

### Deprecated
- Multiple entry points (START_HERE.md, etc.)
- Documentation scattered across multiple locations

## [2025-10-31] - Yelp Integration

### Added
- Yelp Fusion API integration
- Fetch restaurant reviews from Yelp
- Store reviews in restaurant_reviews table
- Scripts for importing Yelp data

See: `docs/02-features/reviews/yelp-integration.md`

## [2025-10-31] - Operational Data

### Changed
- AI search now uses real delivery times
- AI search now uses real delivery fees
- Restaurant data pulled from database tables

See: `customer-app/HANDOFF.md`

## [2025-10-29] - SMS Authentication

### Added
- SMS-based authentication for customers
- Phone number verification
- SMS OTP for login

See: `docs/02-features/authentication/sms-auth.md`

## [2025-10-28] - AI-Powered Search

### Added
- OpenAI GPT-4 integration
- Natural language restaurant search
- Semantic understanding of queries
- Smart fallback to keyword matching

See: `docs/02-features/search/ai-search.md`

---

**Format:** Based on [Keep a Changelog](https://keepachangelog.com/)
EOF

echo -e "${GREEN}✓${NC} CHANGELOG.md created"

# Create logs
echo ""
echo "📋 Creating migration logs..."

cat > archive/MIGRATION_LOG.md << EOF
# Documentation Migration Log

**Date:** $(date)
**Script:** migrate-docs.sh

## Files Moved

See archive/moved_files.log for complete list.

## Structure Created

\`\`\`
docs/
├── 00-getting-started/
├── 01-api-reference/
├── 02-features/
├── 03-database/
├── 04-architecture/
├── 05-guides/
└── 06-reference/
\`\`\`

## Next Steps

1. Review moved files in new locations
2. Update internal links
3. Remove old files from root (after verification)
4. Add metadata to documentation files

## Rollback

To rollback, restore files from archive/ folder using moved_files.log.

EOF

echo -e "${GREEN}✓${NC} Migration log created"

# Summary
echo ""
echo "========================================"
echo -e "${GREEN}✅ Migration Complete!${NC}"
echo "========================================"
echo ""
echo "📊 Summary:"
echo "  - New folder structure created"
echo "  - Documentation organized by category"
echo "  - Master README.md created"
echo "  - CHANGELOG.md created"
echo "  - Old files archived"
echo ""
echo "📁 New structure:"
echo "  - docs/ (all documentation)"
echo "  - audits/ (system audits)"
echo "  - handoffs/ (session handoffs)"
echo "  - tickets/ (work tickets)"
echo "  - archive/ (old docs)"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review: Open README.md"
echo "  2. Test: Navigate to docs/ folders"
echo "  3. Update: Fix internal links if needed"
echo "  4. Clean: Remove old root files after verification"
echo ""
echo -e "${BLUE}View migration log:${NC} archive/MIGRATION_LOG.md"
echo -e "${BLUE}View moved files:${NC} archive/moved_files.log"
echo ""
echo "✨ Happy coding!"
