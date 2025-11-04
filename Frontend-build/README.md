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
- ✅ **Yelp reviews integration** - 394 real reviews, 3.55★ avg (Oct 31, 2025)
- ✅ **Real operational data** - Delivery fees, times, minimum orders from DB
- ✅ **AI-powered search** - OpenAI GPT-4o with real ratings
- ✅ SMS authentication - Supabase Auth phone verification
- ✅ Stripe payments - Complete checkout integration

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
