#!/bin/bash
# Test script to verify installer integration setup

echo "🔍 Aura Installer Integration Test"
echo "================================="

# Check if trigger workflow exists
if [ -f ".github/workflows/trigger-installer-update.yml" ]; then
    echo "✅ Trigger workflow file exists"
else
    echo "❌ Trigger workflow file missing"
    exit 1
fi

# Check workflow syntax
echo ""
echo "📝 Workflow content preview:"
echo "----------------------------"
head -20 .github/workflows/trigger-installer-update.yml

echo ""
echo "🔐 Next steps to complete setup:"
echo "================================"
echo ""
echo "1. Create Personal Access Token:"
echo "   https://github.com/settings/tokens/new"
echo "   Scopes needed: repo, workflow"
echo ""
echo "2. Add PAT as repository secret:"
echo "   https://github.com/OakesekAo/Aura/settings/secrets/actions"
echo "   Name: INSTALLER_PAT"
echo "   Value: [your PAT token]"
echo ""
echo "3. Test by publishing a release:"
echo "   gh release create v1.0.4-test --title \"Test Release\" --notes \"Testing integration\""
echo ""
echo "4. Check workflow runs:"
echo "   gh run list --event release"
echo ""
echo "5. Verify installer repo receives dispatch:"
echo "   Check https://github.com/OakesekAo/aura-installer/actions"

echo ""
echo "📋 Current release status:"
echo "========================="
gh release view v1.0.3-web-installer --json tagName,publishedAt,url | jq -r '
"Tag: " + .tagName,
"Published: " + .publishedAt,
"URL: " + .url'

echo ""
echo "✅ Integration setup complete (pending PAT configuration)"
