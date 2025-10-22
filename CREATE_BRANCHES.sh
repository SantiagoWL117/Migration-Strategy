#!/bin/bash
# 🌿 Create Supabase Branches for Cursor vs Replit Competition
# Run this script in your terminal (not through Cursor tool)

set -e  # Exit on error

echo "🚀 MenuCA V3 - Branch Creation Script"
echo "======================================"
echo ""

# Step 1: Login to Supabase
echo "📝 Step 1: Logging into Supabase..."
echo "This will open a browser window for authentication."
supabase login

echo ""
echo "✅ Login successful!"
echo ""

# Step 2: Link to your production project
echo "📝 Step 2: Linking to production project..."
echo ""
echo "⚠️  You'll need your project ref from:"
echo "   https://supabase.com/dashboard/project/[YOUR-PROJECT-REF]/settings/general"
echo ""
read -p "Enter your project ref: " PROJECT_REF

supabase link --project-ref "$PROJECT_REF"

echo ""
echo "✅ Linked to project: $PROJECT_REF"
echo ""

# Step 3: Create cursor-build branch
echo "📝 Step 3: Creating cursor-build branch (isolated database)..."
echo "This may take 2-3 minutes..."
echo ""

supabase branches create cursor-build

echo ""
echo "✅ cursor-build branch created!"
echo ""

# Step 4: Create replit-build branch
echo "📝 Step 4: Creating replit-build branch (isolated database)..."
echo "This may take 2-3 minutes..."
echo ""

supabase branches create replit-build

echo ""
echo "✅ replit-build branch created!"
echo ""

# Step 5: List all branches
echo "📝 Step 5: Listing all branches..."
echo ""

supabase branches list

echo ""
echo "🎉 SUCCESS! Both branches created!"
echo ""
echo "======================================"
echo "📋 NEXT STEPS:"
echo "======================================"
echo ""
echo "1. Get branch credentials from dashboard:"
echo "   https://supabase.com/dashboard"
echo ""
echo "2. For cursor-build:"
echo "   - Click on 'cursor-build' branch"
echo "   - Copy Project URL"
echo "   - Go to Settings > API"
echo "   - Copy anon key"
echo ""
echo "3. For replit-build:"
echo "   - Click on 'replit-build' branch"
echo "   - Copy Project URL"
echo "   - Go to Settings > API"
echo "   - Copy anon key"
echo ""
echo "4. Share credentials with your AI assistant"
echo ""
echo "5. Start Phase 0 fixes!"
echo ""
echo "🥊 Ready for the Cursor vs Replit cage match!"
echo ""

