Product Requirements Document (PRD): UI Design for Exam Preparation Mobile Application
1. Overview
This PRD outlines the user interface (UI) design requirements for a mobile application designed to assist Adalet Bakanlığı personnel in preparing for the Görevde Yükselme Sınavı and Unvan Değişikliği Sınavı. The application targets candidates from various professions (e.g., Electrical-Electronic Engineer, Construction Engineer, Technician) and provides features such as question pools, random question selection, exam simulations, performance tracking, and motivational notifications. The UI is designed to be intuitive, responsive, and visually consistent, adhering to modern mobile design principles. Non-premium users face ad requirements to unlock additional questions.
2. Design Principles

User-Centric: Prioritize ease of navigation and accessibility for users with varying technical proficiency.
Consistency: Use a unified color scheme, typography, and component style across all screens.
Responsiveness: Ensure compatibility with various screen sizes (iOS and Android).
Minimalism: Avoid clutter, focusing on clear layouts and essential functionality.
Feedback: Provide immediate visual feedback for user interactions (e.g., button presses, correct/incorrect answers).
Branding: Use a professional color palette (navy blue, white, gold accents) without direct Adalet Bakanlığı branding.

3. UI Components

Color Scheme: 
Primary: Navy Blue (#003087)
Secondary: White (#FFFFFF)
Accent: Gold (#FFD700)
Success: Green (#28A745)
Error: Red (#DC3545)


Typography: Use a clean, sans-serif font (e.g., Roboto or Open Sans) with sizes:
Headings: 24px (H1), 20px (H2)
Body Text: 16px (default), adjustable for long questions (12px–18px)
Captions: 14px


Buttons: Rounded corners (8px radius), bold text, and clear states (normal, hover, disabled).
Icons: Material Design icons for intuitive recognition (e.g., star for favoriting, chart for analytics).
Navigation: Bottom navigation bar for primary sections, with a hamburger menu for secondary options.

4. Pages and UI Design
4.1 Login Page
Purpose: Authenticate users via Google or email.UI Elements:

Header: Banner displaying the application name (e.g., "ExamPrep") in bold H1 font, centered at the top.
Input Fields: Email and password fields with placeholder text, styled with a subtle border (2px, navy blue).
Buttons:
"Sign in with Google" button with Google logo (full-width, white background, black text).
"Login" button (full-width, navy blue background, white text).


Links: "Forgot Password?" and "Create Account" links below the buttons, in gold text.
Background: Gradient (navy blue to white) for a professional look.
Feedback: Error messages in red for invalid credentials.

4.2 Registration Page
Purpose: Allow new users to create an account.UI Elements:

Header: "Create Account" heading or app name banner.
Input Fields: Email, password, and confirm password fields, with real-time validation (e.g., password strength indicator).
Checkbox: Terms and privacy policy agreement.
Buttons:
"Sign up with Google" button (same style as login).
"Register" button (navy blue, white text).


Link: "Already have an account? Sign in" link in gold.
Background: Consistent with Login Page for continuity.

4.3 Home/Dashboard
Purpose: Central hub for navigation and quick access.UI Elements:

Header: Personalized greeting ("Welcome, [User Name]") in H1 font.
Cards: Four clickable cards for quick access to:
Question Pool (icon: book)
Exam Simulations (icon: exam)
Starred Questions (icon: star)
Performance Analysis (icon: chart)


Notification Banner: Sliding banner at the top for daily motivational messages (e.g., "Keep practicing, you're almost there!").
Navigation: Bottom bar with icons for Home, Profile, and Settings.
Ad Banner: For non-premium users, a non-intrusive ad at the bottom (e.g., "Watch 3 ads to unlock 5 more questions").
Background: White with subtle navy blue accents.

4.4 Question Pool
Purpose: Browse and answer categorized or random questions.UI Elements:

Filter Bar: Dropdown or tabs for categories (e.g., Electrical Engineer, General Regulations) and a "Random Questions" option.
Question List: Scrollable list of questions with difficulty icons (easy: green, medium: yellow, hard: red).
Random Question Logic: Random questions selected based on the user's profession, ensuring no question repeats within the same session.
Question Card: Displays question text with adjustable font size for long questions (slider or buttons to toggle 12px–18px). Includes multiple-choice options and a "Star" button (gold when starred).
Submit Button: Navy blue, appears after selecting an answer.
Feedback Modal: Pops up after submission, showing correct answer and explanation (green for correct, red for incorrect).
Limit Indicator: For non-premium users, a counter (e.g., "15/20 questions left") and an option to "Watch 3 ads for +5 questions."
Background: White with navy blue headers.

4.5 Exam Simulation
Purpose: Simulate full-length or mini exams.UI Elements:

Header: Displays exam type (e.g., "Machine Engineer Full Exam") and timer (countdown in red).
Question Area: Single question with radio buttons for answers, font size adjustable for long questions (12px–18px).
Navigation: "Next" and "Previous" buttons (navy blue) and a progress bar (e.g., "Question 5/60").
Random Question Logic: Questions randomly selected based on the user's profession, with no repeats in the same session.
End Exam Button: Red button to submit the exam.
Results Modal: Post-exam, shows score, correct/incorrect answers, and option to review explanations.
Background: Minimal white to reduce distractions.

4.6 Starred Questions
Purpose: Review and practice favorited questions.UI Elements:

Filter Bar: Category filter for starred questions.
Question List: Scrollable list of starred questions with adjustable font size for long questions (12px–18px) and "Unstar" button (greyed-out star icon).
Practice Mode: Toggle between individual question view or quiz mode.
Offline Indicator: If offline mode is supported, a badge showing "Available Offline."
Background: Consistent with Question Pool for familiarity.

4.7 Performance Analysis
Purpose: Display performance metrics and recommendations.UI Elements:

Header: "Your Performance" in H1 font.
Charts: Pie chart for correct/incorrect ratios and bar chart for category performance.
Recommendations Section: Text box with suggestions (e.g., "Focus on Programming Languages").
History Table: Scrollable table of past quizzes with scores and dates.
Pop-up: Optional pop-up after quizzes highlighting weak areas.
Background: White with chart accents in navy blue and gold.

4.8 Profile/Settings
Purpose: Manage user information and settings.UI Elements:

Profile Section: Displays name, email, and subscription status (e.g., "Premium until Dec 1, 2025").
Performance Notes: Summary of weak areas (e.g., "More practice needed in General Regulations").
Settings:
Toggle for motivational notifications.
Log out button (red outline).


Link: Button to Subscription Page (gold text).
Background: White with navy blue section dividers.

4.9 Subscription/Payment
Purpose: Handle premium subscription purchases.UI Elements:

Header: "Upgrade to Premium" in H1 font.
Feature List: Bullet points of premium benefits (e.g., unlimited questions, ad-free, random question access).
Payment Form: Secure input for payment details (card number, expiry, etc.).
Validity Note: Text showing subscription validity (e.g., "Valid until Dec 1, 2025").
Purchase Button: Navy blue, "Complete Purchase."
Status Indicator: Shows current subscription status.
Background: White with gold accents for premium branding.

5. Additional UI Considerations

Ad Requirements: Non-premium users must watch 3 ads to unlock 5 additional questions per category. Ads are displayed as banners or interstitials, with a clear "Watch Ads" button (gold, full-width).
Random Question Logic: Random questions are tailored to the user's profession (e.g., Computer Technician gets programming-related questions) and ensured not to repeat within the same session via session tracking.
Font Size Adjustment: For long questions in Question Pool, Exam Simulation, and Starred Questions, users can adjust font size (12px–18px) via a slider or +/- buttons to improve readability.
Notifications: Push notifications for motivational messages use a clean, bold font with a navy blue background and white text.
Offline Mode: If implemented, Starred Questions and select question pools have a distinct offline badge (grey icon).
Accessibility: High-contrast text, scalable fonts, and screen reader support.
Animations: Subtle transitions (e.g., fade-in for modals, slide for navigation) to enhance user experience without distraction.
Ads: For non-premium users, non-intrusive banner ads at the bottom of non-exam screens, with an option to unlock more questions via ads.

6. Technical Notes

Framework: Use a cross-platform framework like React Native for consistent UI across iOS and Android.
Resolution: Optimize for common mobile resolutions (e.g., 1080x1920, 720x1280).
Testing: Ensure UI responsiveness on devices with varying screen sizes and aspect ratios.
Localization: Support Turkish language with proper encoding for special characters (e.g., ç, ş, ı).
