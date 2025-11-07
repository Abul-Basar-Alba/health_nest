import '../models/baby_development_model.dart';

class WeeklyDevelopmentData {
  // Get all weekly development data (Week 1-42)
  static List<BabyDevelopmentModel> getAllWeeks() {
    return List.generate(42, (index) => getWeekData(index + 1));
  }

  // Get specific week data
  static BabyDevelopmentModel getWeekData(int week) {
    switch (week) {
      case 1:
        return BabyDevelopmentModel(
          week: 1,
          sizeComparisonEN: 'Preparing for conception',
          sizeComparisonBN: 'গর্ভধারণের প্রস্তুতি',
          lengthCm: '-',
          weightGrams: '-',
          developmentsEN: [
            'Your body is preparing for ovulation',
            'Menstrual period is ending',
            'Uterine lining is building up',
          ],
          developmentsBN: [
            'আপনার শরীর ডিম্বস্ফোটনের জন্য প্রস্তুত হচ্ছে',
            'মাসিক শেষ হচ্ছে',
            'জরায়ুর আস্তরণ তৈরি হচ্ছে',
          ],
          tipsEN: [
            'Start taking prenatal vitamins',
            'Eat healthy and balanced diet',
            'Avoid alcohol and smoking',
            'Get regular exercise',
          ],
          tipsBN: [
            'প্রসবপূর্ব ভিটামিন গ্রহণ শুরু করুন',
            'স্বাস্থ্যকর ও সুষম খাবার খান',
            'মদ্যপান ও ধূমপান এড়িয়ে চলুন',
            'নিয়মিত ব্যায়াম করুন',
          ],
          symptomsEN: [
            'Menstrual bleeding',
            'Mild cramping',
          ],
          symptomsBN: [
            'মাসিক রক্তপাত',
            'হালকা খিঁচুনি',
          ],
        );

      case 2:
        return BabyDevelopmentModel(
          week: 2,
          sizeComparisonEN: 'Fertilization week',
          sizeComparisonBN: 'নিষেকের সপ্তাহ',
          lengthCm: '-',
          weightGrams: '-',
          developmentsEN: [
            'Ovulation occurs',
            'Egg is released from ovary',
            'Fertilization may happen',
            'Conception occurs around day 14',
          ],
          developmentsBN: [
            'ডিম্বস্ফোটন ঘটে',
            'ডিম্বাশয় থেকে ডিম্বাণু নিঃসৃত হয়',
            'নিষেক ঘটতে পারে',
            '১৪ দিনের কাছাকাছি গর্ভধারণ ঘটে',
          ],
          tipsEN: [
            'Track ovulation',
            'Stay relaxed and stress-free',
            'Continue prenatal vitamins',
            'Maintain healthy diet',
          ],
          tipsBN: [
            'ডিম্বস্ফোটন ট্র্যাক করুন',
            'শিথিল এবং চাপমুক্ত থাকুন',
            'প্রসবপূর্ব ভিটামিন চালিয়ে যান',
            'স্বাস্থ্যকর খাবার বজায় রাখুন',
          ],
          symptomsEN: [
            'Ovulation pain (some women)',
            'Increased cervical mucus',
          ],
          symptomsBN: [
            'ডিম্বস্ফোটন ব্যথা (কিছু মহিলা)',
            'সার্ভিকাল শ্লেষ্মা বৃদ্ধি',
          ],
        );

      case 3:
        return BabyDevelopmentModel(
          week: 3,
          sizeComparisonEN: 'Poppy seed',
          sizeComparisonBN: 'পপি বীজের সমান',
          lengthCm: '0.1 cm',
          weightGrams: '0.1 g',
          developmentsEN: [
            'Fertilized egg implants in uterus',
            'Cells are rapidly dividing',
            'Embryo is forming',
            'Placenta begins to develop',
          ],
          developmentsBN: [
            'নিষিক্ত ডিম্বাণু জরায়ুতে প্রতিস্থাপিত হয়',
            'কোষগুলি দ্রুত বিভাজিত হচ্ছে',
            'ভ্রূণ তৈরি হচ্ছে',
            'প্লাসেন্টা বিকশিত হতে শুরু করে',
          ],
          tipsEN: [
            'Avoid heavy lifting',
            'Get plenty of rest',
            'Stay hydrated',
            'Continue healthy habits',
          ],
          tipsBN: [
            'ভারী জিনিস তোলা এড়িয়ে চলুন',
            'প্রচুর বিশ্রাম নিন',
            'হাইড্রেটেড থাকুন',
            'স্বাস্থ্যকর অভ্যাস চালিয়ে যান',
          ],
          symptomsEN: [
            'Implantation bleeding (light spotting)',
            'Mild cramping',
            'Breast tenderness may begin',
          ],
          symptomsBN: [
            'ইমপ্লান্টেশন রক্তপাত (হালকা দাগ)',
            'হালকা খিঁচুনি',
            'স্তন কোমলতা শুরু হতে পারে',
          ],
        );

      case 4:
        return BabyDevelopmentModel(
          week: 4,
          sizeComparisonEN: 'Chia seed',
          sizeComparisonBN: 'চিয়া বীজের সমান',
          lengthCm: '0.2 cm',
          weightGrams: '0.2 g',
          developmentsEN: [
            'Embryo is now a blastocyst',
            'Heart begins to form',
            'Neural tube developing (brain and spine)',
            'Blood vessels forming',
          ],
          developmentsBN: [
            'ভ্রূণ এখন ব্লাস্টোসিস্ট',
            'হৃদয় গঠন শুরু হয়',
            'নিউরাল টিউব বিকশিত হচ্ছে (মস্তিষ্ক এবং মেরুদণ্ড)',
            'রক্তনালী গঠিত হচ্ছে',
          ],
          tipsEN: [
            'Take folic acid daily (400-800 mcg)',
            'Avoid hot tubs and saunas',
            'Schedule first prenatal appointment',
            'Avoid raw or undercooked foods',
          ],
          tipsBN: [
            'প্রতিদিন ফলিক অ্যাসিড নিন (৪০০-৮০০ এমসিজি)',
            'গরম টব এবং সনা এড়িয়ে চলুন',
            'প্রথম প্রসবপূর্ব অ্যাপয়েন্টমেন্ট নির্ধারণ করুন',
            'কাঁচা বা কম রান্না করা খাবার এড়িয়ে চলুন',
          ],
          symptomsEN: [
            'Missed period',
            'Positive pregnancy test',
            'Fatigue',
            'Mood swings',
          ],
          symptomsBN: [
            'পিরিয়ড মিস',
            'পজিটিভ প্রেগনেন্সি টেস্ট',
            'ক্লান্তি',
            'মেজাজ পরিবর্তন',
          ],
        );

      case 5:
        return BabyDevelopmentModel(
          week: 5,
          sizeComparisonEN: 'Sesame seed',
          sizeComparisonBN: 'তিলের বীজের সমান',
          lengthCm: '0.3 cm',
          weightGrams: '0.3 g',
          developmentsEN: [
            'Heart starts beating (110 bpm)',
            'Brain and spinal cord developing',
            'Tiny buds for arms and legs appearing',
            'Basic circulatory system functioning',
          ],
          developmentsBN: [
            'হৃদস্পন্দন শুরু (১১০ বিপিএম)',
            'মস্তিষ্ক এবং মেরুদণ্ড বিকশিত হচ্ছে',
            'হাত ও পায়ের ছোট কুঁড়ি দেখা যাচ্ছে',
            'মৌলিক সংবহন তন্ত্র কাজ করছে',
          ],
          tipsEN: [
            'Eat small, frequent meals for nausea',
            'Stay active with gentle exercise',
            'Get 8-10 hours of sleep',
            'Keep crackers by bedside for morning sickness',
          ],
          tipsBN: [
            'বমি ভাবের জন্য ছোট, ঘন ঘন খান',
            'মৃদু ব্যায়াম করে সক্রিয় থাকুন',
            '৮-১০ ঘন্টা ঘুমান',
            'সকালের অসুস্থতার জন্য বিছানার পাশে ক্র্যাকার রাখুন',
          ],
          symptomsEN: [
            'Morning sickness (nausea)',
            'Extreme fatigue',
            'Frequent urination',
            'Food aversions or cravings',
          ],
          symptomsBN: [
            'সকালের অসুস্থতা (বমি ভাব)',
            'অতিরিক্ত ক্লান্তি',
            'ঘন ঘন প্রস্রাব',
            'খাবারের প্রতি অনীহা বা আকাঙ্ক্ষা',
          ],
        );

      case 6:
        return BabyDevelopmentModel(
          week: 6,
          sizeComparisonEN: 'Lentil',
          sizeComparisonBN: 'মসুর ডালের সমান',
          lengthCm: '0.6 cm',
          weightGrams: '0.5 g',
          developmentsEN: [
            'Facial features beginning to form',
            'Eyes and ears developing',
            'Heart beating 150 times per minute',
            'Intestines and lungs forming',
          ],
          developmentsBN: [
            'মুখের বৈশিষ্ট্য গঠিত হতে শুরু করেছে',
            'চোখ এবং কান বিকশিত হচ্ছে',
            'হৃদয় প্রতি মিনিটে ১৫০ বার স্পন্দিত হচ্ছে',
            'অন্ত্র এবং ফুসফুস গঠিত হচ্ছে',
          ],
          tipsEN: [
            'Drink ginger tea for nausea relief',
            'Wear comfortable, loose clothing',
            'Avoid strong smells if nauseated',
            'Take prenatal vitamins with food',
          ],
          tipsBN: [
            'বমি ভাব উপশমের জন্য আদা চা পান করুন',
            'আরামদায়ক, ঢিলেঢালা কাপড় পরুন',
            'বমি ভাব হলে তীব্র গন্ধ এড়িয়ে চলুন',
            'খাবারের সাথে প্রসবপূর্ব ভিটামিন নিন',
          ],
          symptomsEN: [
            'Nausea and vomiting',
            'Breast tenderness',
            'Heightened sense of smell',
            'Bloating',
          ],
          symptomsBN: [
            'বমি বমি ভাব এবং বমি',
            'স্তন কোমলতা',
            'ঘ্রাণশক্তি বৃদ্ধি',
            'পেট ফাঁপা',
          ],
        );

      case 8:
        return BabyDevelopmentModel(
          week: 8,
          sizeComparisonEN: 'Raspberry',
          sizeComparisonBN: 'রাস্পবেরির সমান',
          lengthCm: '1.6 cm',
          weightGrams: '1 g',
          developmentsEN: [
            'All major organs are present',
            'Fingers and toes forming',
            'Eyes, nose, and lips developing',
            'Baby is moving (too small to feel)',
          ],
          developmentsBN: [
            'সমস্ত প্রধান অঙ্গ উপস্থিত',
            'আঙুল এবং পায়ের আঙুল গঠিত হচ্ছে',
            'চোখ, নাক এবং ঠোঁট বিকশিত হচ্ছে',
            'শিশু নড়ছে (অনুভব করার জন্য খুব ছোট)',
          ],
          tipsEN: [
            'Stay hydrated - drink 8 glasses of water daily',
            'Avoid caffeine or limit to 200mg/day',
            'Eat protein-rich foods',
            'Rest when tired',
          ],
          tipsBN: [
            'হাইড্রেটেড থাকুন - প্রতিদিন ৮ গ্লাস জল পান করুন',
            'ক্যাফিন এড়িয়ে চলুন বা ২০০মিগ্রা/দিনে সীমাবদ্ধ করুন',
            'প্রোটিন সমৃদ্ধ খাবার খান',
            'ক্লান্ত হলে বিশ্রাম নিন',
          ],
          symptomsEN: [
            'Morning sickness peaks',
            'Increased urination',
            'Mood changes',
            'Light cramping',
          ],
          symptomsBN: [
            'সকালের অসুস্থতা সর্বোচ্চ',
            'প্রস্রাব বৃদ্ধি',
            'মেজাজ পরিবর্তন',
            'হালকা খিঁচুনি',
          ],
        );

      case 12:
        return BabyDevelopmentModel(
          week: 12,
          sizeComparisonEN: 'Plum',
          sizeComparisonBN: 'বরইয়ের সমান',
          lengthCm: '5.4 cm',
          weightGrams: '14 g',
          developmentsEN: [
            'First trimester complete!',
            'All vital organs formed',
            'Reflexes developing',
            'Vocal cords forming',
            'Fingernails and toenails growing',
          ],
          developmentsBN: [
            'প্রথম ত্রৈমাসিক সম্পূর্ণ!',
            'সমস্ত গুরুত্বপূর্ণ অঙ্গ গঠিত',
            'প্রতিবর্ত ক্রিয়া বিকশিত হচ্ছে',
            'কণ্ঠনালী গঠিত হচ্ছে',
            'নখ বৃদ্ধি পাচ্ছে',
          ],
          tipsEN: [
            'Schedule nuchal translucency scan',
            'Morning sickness may ease soon',
            'Start thinking about maternity clothes',
            'Continue prenatal vitamins',
          ],
          tipsBN: [
            'নুকাল ট্রান্সলুসেন্সি স্ক্যান নির্ধারণ করুন',
            'সকালের অসুস্থতা শীঘ্রই কমতে পারে',
            'মাতৃত্বকালীন পোশাক সম্পর্কে ভাবতে শুরু করুন',
            'প্রসবপূর্ব ভিটামিন চালিয়ে যান',
          ],
          symptomsEN: [
            'Less nausea (for many)',
            'Increased energy',
            'Visible baby bump forming',
            'Dizziness',
          ],
          symptomsBN: [
            'কম বমি ভাব (অনেকের জন্য)',
            'শক্তি বৃদ্ধি',
            'দৃশ্যমান শিশুর পেট গঠিত হচ্ছে',
            'মাথা ঘোরা',
          ],
        );

      case 16:
        return BabyDevelopmentModel(
          week: 16,
          sizeComparisonEN: 'Avocado',
          sizeComparisonBN: 'অ্যাভোকাডোর সমান',
          lengthCm: '11.6 cm',
          weightGrams: '100 g',
          developmentsEN: [
            'Baby can make facial expressions',
            'Eyes are moving',
            'Ears are functioning',
            'Gender may be visible on ultrasound',
            'Skeleton hardening',
          ],
          developmentsBN: [
            'শিশু মুখের অভিব্যক্তি করতে পারে',
            'চোখ নড়ছে',
            'কান কাজ করছে',
            'আল্ট্রাসাউন্ডে লিঙ্গ দৃশ্যমান হতে পারে',
            'কঙ্কাল শক্ত হচ্ছে',
          ],
          tipsEN: [
            'Do pelvic floor exercises (Kegels)',
            'Wear supportive bras',
            'Eat iron-rich foods',
            'Stay active with pregnancy-safe exercises',
          ],
          tipsBN: [
            'পেলভিক ফ্লোর ব্যায়াম করুন (কেগেল)',
            'সহায়ক ব্রা পরুন',
            'আয়রন সমৃদ্ধ খাবার খান',
            'গর্ভাবস্থা-নিরাপদ ব্যায়ামের সাথে সক্রিয় থাকুন',
          ],
          symptomsEN: [
            'Feeling baby movements (quickening)',
            'Backaches',
            'Constipation',
            'Increased appetite',
          ],
          symptomsBN: [
            'শিশুর নড়াচড়া অনুভব করা',
            'পিঠে ব্যথা',
            'কোষ্ঠকাঠিন্য',
            'ক্ষুধা বৃদ্ধি',
          ],
        );

      case 20:
        return BabyDevelopmentModel(
          week: 20,
          sizeComparisonEN: 'Banana',
          sizeComparisonBN: 'কলার সমান',
          lengthCm: '25.6 cm',
          weightGrams: '300 g',
          developmentsEN: [
            'Halfway through pregnancy!',
            'Baby can hear sounds',
            'Taste buds forming',
            'Hair growing on head',
            'Regular sleep-wake cycles',
          ],
          developmentsBN: [
            'গর্ভাবস্থার অর্ধেক!',
            'শিশু শব্দ শুনতে পারে',
            'স্বাদের কুঁড়ি গঠিত হচ্ছে',
            'মাথায় চুল গজাচ্ছে',
            'নিয়মিত ঘুম-জাগরণ চক্র',
          ],
          tipsEN: [
            'Anatomy scan around this time',
            'Talk and sing to your baby',
            'Sleep on your left side',
            'Use pregnancy pillow for comfort',
          ],
          tipsBN: [
            'এই সময়ের কাছাকাছি অ্যানাটমি স্ক্যান',
            'আপনার শিশুর সাথে কথা বলুন এবং গান করুন',
            'আপনার বাম দিকে ঘুমান',
            'আরামের জন্য গর্ভাবস্থা বালিশ ব্যবহার করুন',
          ],
          symptomsEN: [
            'Stronger fetal movements',
            'Swelling in feet',
            'Leg cramps',
            'Heartburn',
          ],
          symptomsBN: [
            'শক্তিশালী ভ্রূণের নড়াচড়া',
            'পায়ে ফোলা',
            'পায়ে খিঁচুনি',
            'বুক জ্বালাপোড়া',
          ],
        );

      case 24:
        return BabyDevelopmentModel(
          week: 24,
          sizeComparisonEN: 'Corn on the cob',
          sizeComparisonBN: 'ভুট্টার সমান',
          lengthCm: '30 cm',
          weightGrams: '600 g',
          developmentsEN: [
            'Baby is viable if born early',
            'Lungs developing rapidly',
            'Brain growing quickly',
            'Skin still translucent',
            'Strong kicks and movements',
          ],
          developmentsBN: [
            'প্রাথমিক জন্মেও শিশু টিকতে পারে',
            'ফুসফুস দ্রুত বিকশিত হচ্ছে',
            'মস্তিষ্ক দ্রুত বৃদ্ধি পাচ্ছে',
            'ত্বক এখনও স্বচ্ছ',
            'শক্তিশালী লাথি এবং নড়াচড়া',
          ],
          tipsEN: [
            'Glucose screening test',
            'Monitor baby kicks',
            'Avoid standing for long periods',
            'Elevate legs to reduce swelling',
          ],
          tipsBN: [
            'গ্লুকোজ স্ক্রিনিং পরীক্ষা',
            'শিশুর লাথি পর্যবেক্ষণ করুন',
            'দীর্ঘ সময় দাঁড়িয়ে থাকা এড়িয়ে চলুন',
            'ফোলা কমাতে পা উঁচু করুন',
          ],
          symptomsEN: [
            'Visible baby movements',
            'Braxton Hicks contractions',
            'Carpal tunnel syndrome',
            'Stretch marks',
          ],
          symptomsBN: [
            'দৃশ্যমান শিশুর নড়াচড়া',
            'ব্র্যাক্সটন হিক্স সংকোচন',
            'কার্পাল টানেল সিন্ড্রোম',
            'প্রসারিত চিহ্ন',
          ],
        );

      case 28:
        return BabyDevelopmentModel(
          week: 28,
          sizeComparisonEN: 'Large eggplant',
          sizeComparisonBN: 'বড় বেগুনের সমান',
          lengthCm: '37.6 cm',
          weightGrams: '1000 g',
          developmentsEN: [
            'Third trimester begins!',
            'Eyes can open and close',
            'Lungs capable of breathing air',
            'Adding body fat',
            'May respond to light and sound',
          ],
          developmentsBN: [
            'তৃতীয় ত্রৈমাসিক শুরু!',
            'চোখ খোলা এবং বন্ধ করতে পারে',
            'ফুসফুস বাতাস শ্বাস নিতে সক্ষম',
            'শরীরে চর্বি যোগ হচ্ছে',
            'আলো এবং শব্দে প্রতিক্রিয়া করতে পারে',
          ],
          tipsEN: [
            'Start preparing nursery',
            'Attend prenatal classes',
            'Practice relaxation techniques',
            'Count baby kicks daily',
          ],
          tipsBN: [
            'নার্সারি প্রস্তুত করা শুরু করুন',
            'প্রসবপূর্ব ক্লাসে যোগ দিন',
            'শিথিলকরণ কৌশল অনুশীলন করুন',
            'প্রতিদিন শিশুর লাথি গণনা করুন',
          ],
          symptomsEN: [
            'Shortness of breath',
            'Insomnia',
            'Back pain intensifies',
            'Frequent urination returns',
          ],
          symptomsBN: [
            'শ্বাসকষ্ট',
            'অনিদ্রা',
            'পিঠে ব্যথা তীব্র হয়',
            'ঘন ঘন প্রস্রাব ফিরে আসে',
          ],
        );

      case 32:
        return BabyDevelopmentModel(
          week: 32,
          sizeComparisonEN: 'Large jicama',
          sizeComparisonBN: 'বড় শালগমের সমান',
          lengthCm: '42.4 cm',
          weightGrams: '1700 g',
          developmentsEN: [
            'Baby gaining weight rapidly',
            'Practicing breathing movements',
            'Bones fully formed (but soft)',
            'Fingernails reached fingertips',
            'May be head-down by now',
          ],
          developmentsBN: [
            'শিশু দ্রুত ওজন বাড়াচ্ছে',
            'শ্বাসপ্রশ্বাসের অনুশীলন করছে',
            'হাড় সম্পূর্ণরূপে গঠিত (কিন্তু নরম)',
            'নখ আঙুলের ডগায় পৌঁছেছে',
            'এখন মাথা নিচে থাকতে পারে',
          ],
          tipsEN: [
            'Pack hospital bag',
            'Finalize birth plan',
            'Install car seat',
            'Stay active but rest often',
          ],
          tipsBN: [
            'হাসপাতালের ব্যাগ প্যাক করুন',
            'জন্ম পরিকল্পনা চূড়ান্ত করুন',
            'কার সিট ইনস্টল করুন',
            'সক্রিয় থাকুন তবে প্রায়ই বিশ্রাম নিন',
          ],
          symptomsEN: [
            'Pelvic pressure',
            'Hemorrhoids',
            'Varicose veins',
            'Leaking breasts (colostrum)',
          ],
          symptomsBN: [
            'পেলভিক চাপ',
            'অর্শ',
            'শিরার ফোলা',
            'স্তন থেকে তরল (কোলোস্ট্রাম)',
          ],
        );

      case 36:
        return BabyDevelopmentModel(
          week: 36,
          sizeComparisonEN: 'Romaine lettuce',
          sizeComparisonBN: 'বড় লেটুসের সমান',
          lengthCm: '47.4 cm',
          weightGrams: '2600 g',
          developmentsEN: [
            'Baby is almost full-term',
            'Shed most of lanugo (body hair)',
            'Immune system developing',
            'Fat deposits increase',
            'Descending into pelvis',
          ],
          developmentsBN: [
            'শিশু প্রায় পূর্ণ মেয়াদ',
            'বেশিরভাগ লানুগো ঝরে গেছে',
            'রোগ প্রতিরোধ ব্যবস্থা বিকশিত হচ্ছে',
            'চর্বি জমা বৃদ্ধি',
            'পেলভিসে নামছে',
          ],
          tipsEN: [
            'Weekly doctor visits begin',
            'Watch for signs of labor',
            'Rest and conserve energy',
            'Keep phone charged always',
          ],
          tipsBN: [
            'সাপ্তাহিক ডাক্তার পরিদর্শন শুরু',
            'প্রসব বেদনার লক্ষণ লক্ষ্য করুন',
            'বিশ্রাম নিন এবং শক্তি সংরক্ষণ করুন',
            'ফোন সর্বদা চার্জ রাখুন',
          ],
          symptomsEN: [
            'Braxton Hicks increase',
            'Pelvic discomfort',
            'Frequent urination',
            'Difficulty sleeping',
          ],
          symptomsBN: [
            'ব্র্যাক্সটন হিক্স বৃদ্ধি',
            'পেলভিক অস্বস্তি',
            'ঘন ঘন প্রস্রাব',
            'ঘুমের সমস্যা',
          ],
        );

      case 37:
        return BabyDevelopmentModel(
          week: 37,
          sizeComparisonEN: 'Swiss chard',
          sizeComparisonBN: 'সুইস চার্ডের সমান',
          lengthCm: '48.6 cm',
          weightGrams: '2900 g',
          developmentsEN: [
            'Full-term pregnancy! 🎉',
            'Baby could be born any day',
            'Lungs fully mature',
            'Head engaged in pelvis',
            'Practicing sucking reflex',
          ],
          developmentsBN: [
            'পূর্ণ মেয়াদের গর্ভাবস্থা! 🎉',
            'শিশু যেকোনো দিন জন্ম নিতে পারে',
            'ফুসফুস সম্পূর্ণরূপে পরিপক্ব',
            'মাথা পেলভিসে প্রবেশ করেছে',
            'চোষণ প্রতিবর্ত অনুশীলন করছে',
          ],
          tipsEN: [
            'Have hospital bag ready',
            'Know your route to hospital',
            'Watch for mucus plug',
            'Time contractions when they start',
          ],
          tipsBN: [
            'হাসপাতালের ব্যাগ প্রস্তুত রাখুন',
            'হাসপাতালের রুট জানুন',
            'মিউকাস প্লাগ লক্ষ্য করুন',
            'সংকোচন শুরু হলে সময় গণনা করুন',
          ],
          symptomsEN: [
            'Lightening (baby drops)',
            'Increased vaginal discharge',
            'Nesting instinct',
            'Diarrhea (possible)',
          ],
          symptomsBN: [
            'হালকা অনুভূতি (শিশু নামছে)',
            'যোনি স্রাব বৃদ্ধি',
            'বাসা বাঁধার প্রবৃত্তি',
            'ডায়রিয়া (সম্ভব)',
          ],
        );

      case 40:
        return BabyDevelopmentModel(
          week: 40,
          sizeComparisonEN: 'Small pumpkin',
          sizeComparisonBN: 'ছোট কুমড়ার সমান',
          lengthCm: '51.2 cm',
          weightGrams: '3400 g',
          developmentsEN: [
            'Due date is here!',
            'Baby is ready to be born',
            'All systems fully developed',
            'May have full head of hair',
            'Ready to meet you!',
          ],
          developmentsBN: [
            'নির্ধারিত তারিখ এসেছে!',
            'শিশু জন্ম নিতে প্রস্তুত',
            'সমস্ত সিস্টেম সম্পূর্ণরূপে বিকশিত',
            'সম্পূর্ণ মাথার চুল থাকতে পারে',
            'আপনার সাথে দেখা করতে প্রস্তুত!',
          ],
          tipsEN: [
            'Stay calm and patient',
            'Walk to encourage labor',
            'Practice breathing exercises',
            'Call doctor if water breaks or contractions regular',
          ],
          tipsBN: [
            'শান্ত এবং ধৈর্যশীল থাকুন',
            'প্রসব বেদনা উৎসাহিত করতে হাঁটুন',
            'শ্বাসপ্রশ্বাসের ব্যায়াম অনুশীলন করুন',
            'জল ভাঙলে বা নিয়মিত সংকোচনে ডাক্তারকে ফোন করুন',
          ],
          symptomsEN: [
            'Regular contractions',
            'Water breaking',
            'Back pain',
            'Excitement and anxiety',
          ],
          symptomsBN: [
            'নিয়মিত সংকোচন',
            'জল ভাঙা',
            'পিঠে ব্যথা',
            'উত্তেজনা এবং উদ্বেগ',
          ],
        );

      // Fill remaining weeks with generic data
      default:
        return BabyDevelopmentModel(
          week: week,
          sizeComparisonEN: 'Growing baby',
          sizeComparisonBN: 'বৃদ্ধিপ্রাপ্ত শিশু',
          lengthCm: '${(week * 1.2).toStringAsFixed(1)} cm',
          weightGrams: '${(week * 50).toStringAsFixed(0)} g',
          developmentsEN: [
            'Baby is growing steadily',
            'All organs developing',
            'Preparing for birth',
          ],
          developmentsBN: [
            'শিশু স্থিরভাবে বৃদ্ধি পাচ্ছে',
            'সমস্ত অঙ্গ বিকশিত হচ্ছে',
            'জন্মের জন্য প্রস্তুতি',
          ],
          tipsEN: [
            'Maintain healthy diet',
            'Get regular checkups',
            'Stay active',
            'Rest when needed',
          ],
          tipsBN: [
            'স্বাস্থ্যকর খাদ্য বজায় রাখুন',
            'নিয়মিত পরীক্ষা করুন',
            'সক্রিয় থাকুন',
            'প্রয়োজনে বিশ্রাম নিন',
          ],
          symptomsEN: [
            'Common pregnancy symptoms',
            'Baby movements',
          ],
          symptomsBN: [
            'সাধারণ গর্ভাবস্থার লক্ষণ',
            'শিশুর নড়াচড়া',
          ],
        );
    }
  }

  // Get development data for a specific trimester
  static List<BabyDevelopmentModel> getWeeksByTrimester(int trimester) {
    switch (trimester) {
      case 1:
        return List.generate(12, (i) => getWeekData(i + 1));
      case 2:
        return List.generate(14, (i) => getWeekData(i + 13));
      case 3:
        return List.generate(16, (i) => getWeekData(i + 27));
      default:
        return [];
    }
  }
}
