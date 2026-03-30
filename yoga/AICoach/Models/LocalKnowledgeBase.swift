import Foundation

/// A single knowledge entry that the AI Coach can match against user queries.
struct KnowledgeEntry {
    let topic: String
    let keywords: [String]
    let answer: String
}

/// Local knowledge base for instant, offline AI Coach responses.
/// The coach checks user messages against these entries before calling OpenAI.
struct LocalKnowledgeBase {

    static let entries: [KnowledgeEntry] = [
        // ── PAIN & BODY ──────────────────────────────────────────
        KnowledgeEntry(
            topic: "back pain",
            keywords: ["back pain", "lower back pain", "back ache", "my back hurts"],
            answer: """
            🧘‍♀️ **Yoga for Back Pain Relief**

            Here are some excellent poses to help ease your back pain:

            • **Child's Pose (Balasana)** – Gently stretches the lower back
            • **Cat-Cow Stretch (Marjaryasana-Bitilasana)** – Improves spinal flexibility
            • **Cobra Pose (Bhujangasana)** – Strengthens the spine
            • **Supine Twist (Supta Matsyendrasana)** – Releases tension in the lower back

            Practice these for **5-10 minutes daily** for best results.

            ⚠️ **Avoid**: Heavy lifting, sitting for long periods, and deep forward bends until the pain subsides.

            Stay consistent and listen to your body! 💪
            """
        ),
        KnowledgeEntry(
            topic: "neck pain",
            keywords: ["neck pain", "stiff neck", "pain in neck", "neck hurts"],
            answer: """
            🧘‍♀️ **Yoga for Neck Pain Relief**

            Try these gentle movements to relieve neck stiffness:

            • **Gentle Neck Rolls** – Slowly rotate your head in circles
            • **Cat-Cow Stretch** – Warms up the entire spine including the neck
            • **Side Stretch** – Tilt your ear toward each shoulder gently
            • **Shoulder Rolls** – Release tension in neck and shoulders

            ⚠️ **Avoid**: Sudden neck movements and poor posture (especially while using phones/laptops).

            Practice these throughout the day for relief! 🌿
            """
        ),
        KnowledgeEntry(
            topic: "shoulder pain",
            keywords: ["shoulder pain", "stiff shoulder", "pain in shoulder", "shoulder hurts"],
            answer: """
            🧘‍♀️ **Yoga for Shoulder Pain Relief**

            These poses will help loosen tight shoulders:

            • **Eagle Arms Stretch (Garudasana Arms)** – Deep shoulder opener
            • **Thread the Needle Pose** – Releases upper back and shoulder tension
            • **Wall Stretch** – Gentle chest and shoulder opener
            • **Arm Circles** – Improves range of motion

            Practice these daily, holding each stretch for 30 seconds. Your shoulders will thank you! 💆‍♀️
            """
        ),
        KnowledgeEntry(
            topic: "knee pain",
            keywords: ["knee pain", "pain in knee", "my knee hurts", "knee hurts"],
            answer: """
            🧘‍♀️ **Yoga for Knee Pain Relief**

            Strengthen and protect your knees with these gentle exercises:

            • **Supported Bridge Pose (Setu Bandhasana)** – Strengthens muscles around the knee
            • **Straight Leg Raise** – Builds quadricep strength
            • **Gentle Hamstring Stretch** – Reduces tension on the knee joint

            ⚠️ **Avoid**: Jumping, running, and deep squats until the pain improves.

            Always warm up before exercising and use a yoga mat for cushioning! 🙏
            """
        ),
        KnowledgeEntry(
            topic: "hip pain",
            keywords: ["hip pain", "tight hips", "hip hurts", "pain in hip"],
            answer: """
            🧘‍♀️ **Yoga for Hip Pain Relief**

            Open up those hips with these amazing poses:

            • **Butterfly Pose (Baddha Konasana)** – Opens inner hips
            • **Pigeon Pose (Kapotasana)** – Deep hip flexor stretch
            • **Happy Baby Pose (Ananda Balasana)** – Releases hip tension
            • **Seated Hip Stretches** – Gentle and effective

            Hold each pose for 30-60 seconds and breathe deeply. Consistency is key! 🌟
            """
        ),
        KnowledgeEntry(
            topic: "leg pain",
            keywords: ["leg pain", "pain in leg", "my legs hurt", "leg hurts", "leg cramps"],
            answer: """
            🧘‍♀️ **Relief for Leg Pain**

            Here's what you can do:

            • **Rest** – Give your legs a break
            • **Gentle Leg Stretches** – Stretch your calves and hamstrings slowly
            • **Stay Hydrated** – Drink enough water to prevent cramps
            • **Legs-Up-The-Wall Pose (Viparita Karani)** – Amazing for tired, achy legs

            This restorative pose helps improve circulation and reduce swelling. Try it for 5-10 minutes! 💧
            """
        ),
        KnowledgeEntry(
            topic: "foot pain",
            keywords: ["foot pain", "heel pain", "pain in foot", "feet hurt"],
            answer: """
            🦶 **Relief for Foot Pain**

            Take care of your feet with these tips:

            • **Warm Water Soak** – Soak feet in warm water for 15-20 minutes
            • **Foot Stretches** – Roll a tennis ball under your foot
            • **Toe Stretches** – Spread and wiggle your toes
            • **Avoid** standing for long periods without breaks

            Your feet carry you through your entire yoga journey — treat them well! 🙏
            """
        ),

        // ── HEAD & GENERAL ───────────────────────────────────────
        KnowledgeEntry(
            topic: "headache",
            keywords: ["headache", "migraine", "head pain", "head hurts"],
            answer: """
            🧘‍♀️ **Yoga for Headache Relief**

            Natural ways to ease your headache:

            • **Child's Pose (Balasana)** – Calms the mind and relieves tension
            • **Deep Breathing (Pranayama)** – Increases oxygen flow
            • **Drink Water** – Dehydration is a common headache trigger
            • **Reduce Screen Time** – Give your eyes a break

            Try resting in a dark, quiet room while practicing deep breathing for 5-10 minutes. 🌿
            """
        ),
        KnowledgeEntry(
            topic: "period pain",
            keywords: ["period pain", "cramps", "stomach pain during periods", "menstrual pain", "period cramps"],
            answer: """
            🧘‍♀️ **Yoga for Period Pain Relief**

            These gentle poses can help ease menstrual cramps:

            • **Child's Pose (Balasana)** – Relaxes the lower abdomen
            • **Reclining Bound Angle Pose (Supta Baddha Konasana)** – Opens the pelvis
            • **Deep Breathing** – Calms and reduces pain perception
            • **Warm Water** – Place a warm compress on your lower belly

            Be gentle with yourself during this time. Rest when needed! 💜
            """
        ),
        KnowledgeEntry(
            topic: "stomach pain",
            keywords: ["stomach pain", "abdomen pain", "stomach ache", "tummy pain", "belly pain"],
            answer: """
            🌿 **Relief for Stomach Pain**

            Here's what can help:

            • **Eat Light Food** – Stick to easily digestible meals
            • **Drink Warm Water** – Soothes the digestive system
            • **Avoid Oily/Spicy Food** – Let your stomach rest
            • **Rest** – Lie down in a comfortable position

            If the pain persists, please consult a healthcare professional. 🙏
            """
        ),
        KnowledgeEntry(
            topic: "constipation",
            keywords: ["constipation", "digestive issue", "cannot poop", "bloating", "digestion problem"],
            answer: """
            🌿 **Yoga for Digestive Health**

            Beat constipation naturally:

            • **Drink More Water** – At least 2-3 liters daily
            • **Eat Fiber-Rich Foods** – Fruits, vegetables, whole grains
            • **Wind-Relieving Pose (Pawanmuktasana)** – Massages abdominal organs
            • **Gentle Twists** – Stimulate digestive movement

            Morning warm water with lemon can also help kickstart your digestion! 🍋
            """
        ),

        // ── MENTAL WELLNESS ──────────────────────────────────────
        KnowledgeEntry(
            topic: "stress and anxiety",
            keywords: ["stress", "anxiety", "tension", "feeling stressed", "anxious", "worried", "panic", "mental health"],
            answer: """
            🧘‍♀️ **Yoga for Stress & Anxiety Relief**

            Calm your mind with these practices:

            • **Child's Pose (Balasana)** – Grounding and calming
            • **Legs-Up-The-Wall Pose (Viparita Karani)** – Activates relaxation response
            • **Deep Breathing (4-7-8 Technique)** – Inhale 4s, Hold 7s, Exhale 8s
            • **Meditation** – Even 5 minutes of quiet sitting helps

            Remember: Your yoga mat is your safe space. You're doing great! 🌟💙
            """
        ),
        KnowledgeEntry(
            topic: "sleep problem",
            keywords: ["sleep problem", "insomnia", "cannot sleep", "can't sleep", "trouble sleeping", "sleep issue"],
            answer: """
            🌙 **Yoga for Better Sleep**

            Create a calming bedtime routine:

            • **Avoid Phones** – Put screens away 30 minutes before bed
            • **Warm Milk** – Contains tryptophan which promotes sleep
            • **Deep Breathing (Pranayama)** – Slow, deep breaths calm the nervous system
            • **Legs-Up-The-Wall Pose** – Practice for 5 minutes before bed
            • **Body Scan Meditation** – Relax each body part progressively

            Consistency is key — try to sleep and wake at the same time daily! 😴✨
            """
        ),

        // ── DIET PLANS ───────────────────────────────────────────
        KnowledgeEntry(
            topic: "weight loss diet",
            keywords: ["weight loss", "lose weight", "fat loss diet", "reduce weight", "slim down", "weight loss diet"],
            answer: """
            🥗 **Weight Loss Diet Plan**

            Here's a balanced daily plan:

            🌅 **Breakfast**: Oats with fresh fruits
            🌞 **Lunch**: Rice or chapati with vegetables
            🍎 **Snack**: Fruits or a handful of nuts
            🌙 **Dinner**: Soup and salad

            ❌ **Avoid**: Sugar, fried foods, and soft drinks
            ✅ **Do**: Drink plenty of water, eat slowly, and don't skip meals

            Combine this with your yoga practice for amazing results! 💪🔥
            """
        ),
        KnowledgeEntry(
            topic: "muscle gain diet",
            keywords: ["muscle gain", "build muscle", "gain weight", "muscle building", "bulk up"],
            answer: """
            💪 **Muscle Gain Diet Plan**

            Fuel your body for growth:

            🌅 **Breakfast**: Eggs and milk (or protein smoothie)
            🌞 **Lunch**: Rice, chicken or paneer curry
            🍌 **Snack**: Banana and nuts
            🌙 **Dinner**: Chapati with chicken, paneer, or dal

            🔑 **Key Tips**:
            • Eat more protein (1.6-2g per kg of body weight)
            • Don't skip post-workout nutrition
            • Stay consistent with meals

            Pair this with strength-building yoga poses! 🏋️‍♂️
            """
        ),
        KnowledgeEntry(
            topic: "vegetarian diet",
            keywords: ["vegetarian diet", "veg diet", "veg food", "vegetarian meal", "plant based"],
            answer: """
            🥬 **Vegetarian Diet Plan**

            A wholesome vegetarian day:

            🌅 **Breakfast**: Oats and banana (or idli/poha)
            🌞 **Lunch**: Rice, dal, and seasonal vegetables
            🍏 **Snack**: Fruits and mixed nuts
            🌙 **Dinner**: Chapati, paneer curry, and fresh salad

            🌿 Great vegetarian protein sources: dal, paneer, tofu, chickpeas, quinoa, and nuts.

            A yogic diet is naturally plant-rich — you're on the right path! 🧘‍♀️
            """
        ),
        KnowledgeEntry(
            topic: "non vegetarian diet",
            keywords: ["non veg diet", "non vegetarian diet", "protein diet", "non veg food", "meat diet"],
            answer: """
            🍗 **Non-Vegetarian Diet Plan**

            A protein-packed daily plan:

            🌅 **Breakfast**: Eggs and toast (or egg omelette)
            🌞 **Lunch**: Rice, grilled chicken, vegetables
            🍎 **Snack**: Fruits and yogurt
            🌙 **Dinner**: Fish or chicken soup with salad

            🔑 **Tips**: Choose lean meats, grill or bake instead of frying, and balance with plenty of vegetables!

            Great for building strength alongside your yoga practice! 💪
            """
        ),
        KnowledgeEntry(
            topic: "diabetes diet",
            keywords: ["diabetes", "high sugar", "sugar patient food", "diabetic diet", "blood sugar"],
            answer: """
            🩺 **Diet Tips for Diabetes Management**

            Smart food choices for stable blood sugar:

            ✅ **Eat**: Whole grains, green vegetables, nuts, and small portions of fruits
            ❌ **Avoid**: Sweets, refined sugar, white bread, and cold drinks
            💧 **Hydration**: Drink plenty of water

            🔑 **Key Tips**:
            • Eat smaller, frequent meals
            • Choose low glycemic index foods
            • Include protein in every meal

            Yoga can also help regulate blood sugar — especially Pranayama! 🧘‍♀️
            """
        ),
        KnowledgeEntry(
            topic: "high blood pressure diet",
            keywords: ["high bp", "blood pressure", "bp problem", "hypertension", "high blood pressure"],
            answer: """
            ❤️ **Diet Tips for High Blood Pressure**

            Heart-healthy eating habits:

            ✅ **Eat**: Fruits, vegetables, whole grains, and lean protein
            ❌ **Avoid**: Excess salt, junk food, processed foods
            💧 **Hydration**: Stay well-hydrated

            🔑 **Key Tips**:
            • Reduce sodium intake
            • Eat potassium-rich foods (bananas, spinach)
            • Limit caffeine and alcohol

            Combine with gentle yoga and deep breathing for best results! 🌿
            """
        ),

        // ── MEAL IDEAS ───────────────────────────────────────────
        KnowledgeEntry(
            topic: "healthy breakfast",
            keywords: ["breakfast", "healthy breakfast", "morning food", "breakfast ideas"],
            answer: """
            🌅 **Healthy Breakfast Ideas**

            Start your day right:

            • 🥣 Oats with fresh fruits and honey
            • 🥚 Eggs and whole grain toast
            • 🍚 Idli or Poha with chutney
            • 🥤 Smoothie with banana, milk, and nuts
            • 🥜 A handful of mixed nuts with milk

            A good breakfast fuels your morning yoga practice! ☀️
            """
        ),
        KnowledgeEntry(
            topic: "healthy lunch",
            keywords: ["lunch", "healthy lunch", "afternoon food", "lunch ideas"],
            answer: """
            🌞 **Healthy Lunch Ideas**

            Nourishing midday meals:

            • 🍚 Rice with dal and seasonal vegetables
            • 🫓 Chapati with paneer or chicken curry
            • 🥗 Grilled chicken with fresh salad
            • 🍚 Curd rice with pickle

            Keep your lunch balanced with protein, carbs, and vegetables! 🥦
            """
        ),
        KnowledgeEntry(
            topic: "healthy dinner",
            keywords: ["dinner", "healthy dinner", "night food", "dinner ideas"],
            answer: """
            🌙 **Healthy Dinner Ideas**

            Light and nourishing evening meals:

            • 🥣 Warm soup (vegetable or chicken)
            • 🥗 Fresh salad with dressing
            • 🫓 Chapati with vegetables
            • 🍗 Grilled chicken or paneer

            💡 **Tip**: Eat dinner at least 2-3 hours before bedtime. Keep it light! ✨
            """
        ),
        KnowledgeEntry(
            topic: "healthy snacks",
            keywords: ["snacks", "healthy snacks", "evening snacks", "snack ideas"],
            answer: """
            🍎 **Healthy Snack Ideas**

            Smart snacking options:

            • 🍊 Fresh fruits (apple, banana, orange)
            • 🥜 Mixed nuts and seeds
            • 🥛 Yogurt with honey
            • 🫘 Roasted chickpeas
            • 🥚 Boiled eggs
            • 🌱 Sprouts salad

            Healthy snacks keep your energy up between meals! 💪
            """
        ),
        KnowledgeEntry(
            topic: "water reminder",
            keywords: ["water", "drink water", "hydration", "how much water", "dehydrated"],
            answer: """
            💧 **Stay Hydrated!**

            Water is essential for your yoga practice and overall health:

            • Drink at least **2-3 liters** of water every day
            • Start your day with a glass of warm water
            • Carry a water bottle with you
            • Drink water before and after yoga sessions

            Proper hydration reduces body pain, tiredness, and improves flexibility! 🌊✨
            """
        ),
    ]

    /// Finds the best matching knowledge entry for a given user message.
    /// Returns `nil` if no strong match is found.
    static func findAnswer(for query: String) -> String? {
        let normalizedQuery = query.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Score each entry by counting keyword matches
        var bestMatch: (entry: KnowledgeEntry, score: Int)?

        for entry in entries {
            var score = 0
            for keyword in entry.keywords {
                if normalizedQuery.contains(keyword.lowercased()) {
                    // Longer keyword matches are weighted more
                    score += keyword.count
                }
            }
            // Also check topic match
            if normalizedQuery.contains(entry.topic.lowercased()) {
                score += entry.topic.count * 2
            }

            if score > 0 {
                if bestMatch == nil || score > bestMatch!.score {
                    bestMatch = (entry, score)
                }
            }
        }

        // Only return if we have a meaningful match (minimum threshold)
        guard let match = bestMatch, match.score >= 3 else {
            return nil
        }

        return match.entry.answer
    }
}
