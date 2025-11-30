#!/bin/bash

# HealthNest - Firebase Hosting Deployment Script
# This script automates the deployment process to Firebase Hosting

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}🚀 HealthNest - Cloud Deployment Script${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}⚠️  Firebase CLI is not installed${NC}"
    echo "Installing Firebase CLI..."
    npm install -g firebase-tools
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Step 1: Clean previous builds
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}Step 1: Cleaning previous builds...${NC}"
echo "═══════════════════════════════════════════════════════════════"
flutter clean
echo -e "${GREEN}✅ Clean completed${NC}"
echo ""

# Step 2: Get dependencies
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}Step 2: Getting dependencies...${NC}"
echo "═══════════════════════════════════════════════════════════════"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 3: Run tests (optional)
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}Step 3: Running tests (optional)...${NC}"
echo "═══════════════════════════════════════════════════════════════"
read -p "Run tests before deployment? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    flutter test || {
        echo -e "${RED}❌ Tests failed${NC}"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    }
    echo -e "${GREEN}✅ Tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  Tests skipped${NC}"
fi
echo ""

# Step 4: Build Flutter Web
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}Step 4: Building Flutter Web (Release Mode)...${NC}"
echo "═══════════════════════════════════════════════════════════════"
flutter build web --release --no-tree-shake-icons
echo -e "${GREEN}✅ Build completed${NC}"
echo ""

# Step 5: Check build output
BUILD_SIZE=$(du -sh build/web | cut -f1)
echo -e "${BLUE}📦 Build size: ${BUILD_SIZE}${NC}"
echo ""

# Step 6: Deploy to Firebase Hosting
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}Step 5: Deploying to Firebase Hosting...${NC}"
echo "═══════════════════════════════════════════════════════════════"

# Ask for deployment confirmation
echo -e "${YELLOW}You are about to deploy to: healthnest-ae7bb.web.app${NC}"
read -p "Continue with deployment? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Deployment cancelled${NC}"
    exit 1
fi

# Deploy
firebase deploy --only hosting

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ Deployment Successful!${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}🌐 Your app is live at:${NC}"
echo -e "${GREEN}   https://healthnest-ae7bb.web.app${NC}"
echo ""
echo -e "${BLUE}📊 Firebase Console:${NC}"
echo "   https://console.firebase.google.com/project/healthnest-ae7bb/hosting"
echo ""
echo -e "${BLUE}📈 View Analytics:${NC}"
echo "   https://console.firebase.google.com/project/healthnest-ae7bb/analytics"
echo ""
echo "═══════════════════════════════════════════════════════════════"

# Optional: Open in browser
read -p "Open the deployed app in browser? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://healthnest-ae7bb.web.app"
    elif command -v open &> /dev/null; then
        open "https://healthnest-ae7bb.web.app"
    else
        echo "Please open: https://healthnest-ae7bb.web.app"
    fi
fi

echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"
echo ""
