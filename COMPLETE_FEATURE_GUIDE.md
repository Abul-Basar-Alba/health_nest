# HealthNest - Complete Feature Documentation

## 🎯 Overview
HealthNest is a comprehensive health tracking app with AI-powered recommendations, BMI calculations, nutrition tracking, and workout history.

---

## 📱 Core Features

### 1. **BMI Calculator** 💪
**Location:** `lib/src/screens/calculators/premium_bmi_calculator_screen.dart`

**Features:**
- Premium UI with purple gradient background
- Input: Age, Weight, Height, Gender, Activity Level
- Calculations:
  - BMI with category (Underweight, Normal, Overweight, Obese)
  - BMR (Basal Metabolic Rate)
  - Daily Calorie Needs
  - Ideal Weight (Devine formula)
  - Body Fat Percentage (estimation)
- Premium locked features for free users
- **Save to History** functionality
- Post-save options:
  - **Recommendations** button → AI health coach
  - **Nutrition Plan** button → Food tracking

**Routes:**
- `/premium-bmi-calculator` - Main calculator
- `/recommendations` - AI recommendations
- `/nutrition` - Food tracker

---

### 2. **History Tracking** 📊
**Location:** `lib/src/screens/history/history_screen.dart`

**Features:**
- **4 Tabs:**
  - **All** - Overview with weekly analytics
  - **BMI** - BMI calculation history
  - **Activity** - Workout/activity logs
  - **Nutrition** - Food consumption logs

**Weekly Analytics Card:**
- Total workouts this week
- Total minutes exercised
- Average daily calories

**History Cards Display:**
- BMI History:
  - BMI value with color-coded category
  - Weight, height, activity level
  - Date and time
- Activity History:
  - Activity level with emoji
  - Exercise type, duration, calories burned
  - Steps, distance
- Nutrition History:
  - Food name with meal type emoji
  - Calories, protein, carbs, fats
  - Meal type (Breakfast/Lunch/Dinner/Snacks)

**Route:** `/history`

---

### 3. **AI Recommendations** 🤖
**Location:** `lib/src/screens/recommendation_screen.dart`

**Features:**
- **AI Health Coach Chatbot**
- Real-time conversation with Gemini AI
- Context-aware responses based on:
  - User profile (age, weight, height, gender)
  - BMI history
  - Activity history
  - Nutrition logs
- Personalized health tips
- Workout suggestions
- Nutrition advice

**Chat Interface:**
- User messages (right side, blue)
- AI responses (left side, green)
- Send button with loading indicator
- Keyboard-aware scroll

**For New Users:**
- Welcome message
- Feature showcase
- Motivational content

**Route:** `/recommendations`

---

### 4. **Nutrition Tracking** 🍽️
**Location:** `lib/src/screens/nutrition_screen.dart`

**Features:**
- **Food Search:**
  - Search food database
  - View popular foods
  - Real-time search suggestions

- **Food Details:**
  - Calories, Protein, Fat, Carbs
  - Detailed nutritional information

- **Log Meal:**
  - Select meal type (Breakfast/Lunch/Dinner/Snacks)
  - Automatic save to history
  - Portion size tracking
  - Unit selection (servings, grams, etc.)

- **Today's Log:**
  - View all meals for today
  - Edit/delete entries
  - Daily calorie summary
  - Macro breakdown

**Route:** `/nutrition`

---

## 🔧 Backend Services

### **HistoryService** 
**Location:** `lib/src/services/history_service.dart`

**Methods:**
```dart
// BMI History
saveBMIHistory({userId, bmi, category, weight, height, age, gender, activityLevel...})
getBMIHistory(userId) → Stream<List<BMIHistoryModel>>
getBMIHistoryByDateRange(userId, startDate, endDate)

// Activity History
saveActivityHistory({userId, activityLevel, exerciseType, duration, calories...})
getActivityHistory(userId) → Stream<List<ActivityHistoryModel>>

// Nutrition History
saveNutritionHistory({userId, mealType, foodName, calories, protein, carbs, fats...})
getNutritionHistory(userId) → Stream<List<NutritionHistoryModel>>
getTodaysFoodLog(userId)
deleteNutritionEntry(entryId)

// Analytics
getWeeklyAnalytics(userId) → {bmiTrend, totalWorkouts, totalMinutes, averageCalories}
```

---

## 📦 Data Models

### **BMIHistoryModel**
```dart
{
  id, userId, date, bmi, category, weight, height, 
  age, gender, activityLevel, bmr, dailyCalories, 
  idealWeight, bodyFat, createdAt
}
```

### **ActivityHistoryModel**
```dart
{
  id, userId, date, activityLevel, exerciseType, 
  durationMinutes, caloriesBurned, steps, distanceKm, 
  notes, createdAt
}
```

### **NutritionHistoryModel**
```dart
{
  id, userId, date, mealType, foodName, calories, 
  protein, carbs, fats, quantity, unit, imageUrl, 
  notes, createdAt
}
```

---

## 🎨 UI/UX Features

### **Color Scheme:**
- **Primary Gradient:** Purple (#667eea) → Dark Purple (#764ba2) → Pink (#F093FB)
- **Accent Colors:**
  - Success: Green (#00B894)
  - Warning: Amber (#FFD700)
  - Error: Red
  - Info: Blue

### **Animations:**
- FadeIn, FadeInUp, FadeInDown (animate_do package)
- Smooth tab transitions
- Loading indicators
- Success notifications

### **Glass Morphism:**
- Semi-transparent cards
- Backdrop blur effects
- Border highlights
- Elevated shadows

---

## 🚀 User Flow

### **Complete User Journey:**

1. **Sign Up/Login**
   - Create account with Firebase Auth
   - Profile setup (age, weight, height, gender)

2. **Home Screen**
   - Quick actions dashboard
   - BMI calculator button
   - Nutrition tracker button
   - History button

3. **Calculate BMI**
   - Enter metrics
   - Select activity level
   - Calculate results
   - View premium metrics (if premium user)
   - **Save Result** to history
   - Get **Recommendations**
   - Access **Nutrition Plan**

4. **Track Nutrition**
   - Search foods
   - View nutritional info
   - Select meal type
   - Log meal → Saves to history
   - View daily summary

5. **View History**
   - Check weekly progress
   - Review BMI trends
   - Track activity logs
   - Monitor nutrition intake
   - Filter by category

6. **Get AI Recommendations**
   - Chat with AI coach
   - Get personalized tips
   - Ask health questions
   - Receive workout suggestions
   - Get nutrition advice

---

## 🔐 Premium Features

### **Free Users:**
- Basic BMI calculation
- Basic nutrition search
- Limited history (7 days)
- Basic recommendations

### **Premium Users:**
- Advanced BMI metrics (ideal weight, body fat %)
- Unlimited history
- Detailed analytics
- Priority AI responses
- Meal planning
- Workout schedules
- Progress photos
- Export data

**Upgrade Prompt:**
- Shown on locked features
- Benefits list
- Upgrade button → `/premium-services`

---

## 📝 Firebase Structure

```
Firestore Collections:
├── users/
│   └── {userId}/
│       ├── profile data
│       ├── isPremium
│       └── settings
├── bmi_history/
│   └── {recordId}/
│       ├── userId
│       ├── date
│       ├── bmi, weight, height
│       └── calculations
├── activity_history/
│   └── {recordId}/
│       ├── userId
│       ├── date
│       ├── activityLevel
│       └── exercise data
└── nutrition_history/
    └── {recordId}/
        ├── userId
        ├── date
        ├── mealType
        └── food data
```

---

## 🧪 Testing Checklist

### **BMI Calculator:**
- [ ] Input validation works
- [ ] Calculations accurate
- [ ] Activity chips visible
- [ ] Gender selection works
- [ ] Save button saves to history
- [ ] Success message appears
- [ ] Recommendations button navigates
- [ ] Nutrition button navigates

### **History Screen:**
- [ ] All tabs display correctly
- [ ] Weekly analytics shows data
- [ ] BMI records appear
- [ ] Activity logs visible
- [ ] Nutrition entries display
- [ ] Empty states work
- [ ] Real-time updates

### **Nutrition Screen:**
- [ ] Search works
- [ ] Food details show
- [ ] Meal type selector appears
- [ ] Logging saves to history
- [ ] Success notification shows
- [ ] History updates

### **Recommendations:**
- [ ] Chat interface works
- [ ] Messages send/receive
- [ ] AI responds accurately
- [ ] Loading indicator shows
- [ ] Welcome screen for new users
- [ ] Scroll works properly

---

## 🐛 Known Issues & Fixes

### **Fixed:**
✅ Activity level chips white-on-white → Changed to white bg with black text
✅ Purple gradient harsh → Still using purple (user preference)
✅ Old history screen duplicate → Deleted, using new one
✅ Nutrition using old history model → Updated to new HistoryService

### **To Monitor:**
⚠️ AI response times (Gemini API)
⚠️ Firestore query limits
⚠️ Image uploads (nutrition photos)

---

## 📚 Dependencies

```yaml
firebase_core: ^4.1.1
firebase_auth: ^6.1.0
cloud_firestore: ^6.0.2
provider: ^6.1.2
animate_do: ^3.3.9
fl_chart: ^0.69.0
intl: ^0.19.0
```

---

## 🎯 Future Enhancements

1. **Progress Photos** 📸
   - Before/after comparison
   - Timeline view
   - Body measurement tracking

2. **Habit Streaks** 🔥
   - Daily login streak
   - Workout consistency
   - Nutrition logging streak

3. **Achievements/Badges** 🏆
   - First BMI calculation
   - 7-day streak
   - 100 meals logged
   - Weight goal achieved

4. **Social Features** 👥
   - Share progress
   - Friend challenges
   - Leaderboards

5. **Water Intake** 💧
   - Daily water goal
   - Reminder notifications
   - Glass counter

6. **Sleep Tracker** 😴
   - Sleep duration
   - Sleep quality
   - Bedtime reminders

7. **Step Counter** 👟
   - Daily step goal
   - Distance traveled
   - Integration with pedometer

---

## 📞 Support

For issues or questions:
- Admin Contact: `/admin-contact`
- Documentation: `/documentation`
- Premium Support: Available for premium users

---

**Last Updated:** October 27, 2025
**Version:** 1.0.0
**Author:** HealthNest Development Team
