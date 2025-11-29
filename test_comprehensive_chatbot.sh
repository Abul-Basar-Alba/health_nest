#!/bin/bash
# Comprehensive Test Script for HealthNest AI Chatbot

echo "🧪 HealthNest AI Comprehensive Test"
echo "===================================="
echo ""

BASE_URL="http://192.168.0.108:5000"

# Test function
test_question() {
    local question="$1"
    local profile='{"age": 25, "gender": "male", "weight": 70, "height": 170, "activity": "moderate"}'
    
    echo "❓ Question: $question"
    echo "---"
    
    response=$(curl -s -X POST "$BASE_URL/chat" \
        -H "Content-Type: application/json" \
        -d "{\"message\": \"$question\", \"profile\": $profile}")
    
    # Extract and print first 300 chars of response
    echo "$response" | python3 -c "import sys, json; r=json.load(sys.stdin)['response']; print(r[:300] + '...' if len(r) > 300 else r)"
    echo ""
    echo "===================================="
    echo ""
}

# Test 1: App Info
echo "📱 TEST 1: App Information"
test_question "HealthNest app কি?"

# Test 2: BMI
echo "📊 TEST 2: BMI Calculator"
test_question "আমার BMI কত?"

# Test 3: Weight Loss
echo "🎯 TEST 3: Weight Loss"
test_question "ওজন কমাতে কি করবো?"

# Test 4: Nutrition
echo "🥗 TEST 4: Nutrition"
test_question "পুষ্টি পরিকল্পনা দাও"

# Test 5: Water
echo "💧 TEST 5: Water Intake"
test_question "কত পানি পান করবো?"

# Test 6: Sleep
echo "😴 TEST 6: Sleep"
test_question "কত ঘণ্টা ঘুমাবো?"

# Test 7: Exercise
echo "💪 TEST 7: Exercise"
test_question "কি ব্যায়াম করবো?"

# Test 8: Pregnancy
echo "🤰 TEST 8: Pregnancy"
test_question "গর্ভাবস্থায় কি করবো?"

# Test 9: Women's Health
echo "👩 TEST 9: Women's Health"
test_question "পিরিয়ড ব্যথা কমাতে কি করবো?"

# Test 10: Medicine
echo "💊 TEST 10: Medicine"
test_question "ঔষধ কিভাবে ট্র্যাক করবো?"

# Test 11: Blood Pressure
echo "🩸 TEST 11: Blood Pressure"
test_question "Blood pressure নিয়ন্ত্রণ করবো কিভাবে?"

# Test 12: Diabetes
echo "🩸 TEST 12: Diabetes"
test_question "Diabetes থেকে বাঁচতে কি করবো?"

# Test 13: Mental Health
echo "🧠 TEST 13: Mental Health"
test_question "মানসিক চাপ কমাতে কি করবো?"

# Test 14: Health Diary
echo "📝 TEST 14: Health Diary"
test_question "Health diary কি?"

# Test 15: Family Health
echo "👨‍👩‍👧‍👦 TEST 15: Family Health"
test_question "পরিবারের স্বাস্থ্য কিভাবে ট্র্যাক করবো?"

echo ""
echo "✅ All 15 tests completed!"
echo "===================================="
