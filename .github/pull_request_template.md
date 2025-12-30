## 📝 Description

<!-- PR এর brief description লিখুন। কী changes করা হয়েছে এবং কেন? -->

## 🏷️ Type of Change

<!-- যেটি applicable সেটি check করুন (x দিয়ে) -->

- [ ] 🐛 Bug fix (existing issue fix, non-breaking)
- [ ] ✨ New feature (নতুন functionality যোগ করা, non-breaking)
- [ ] 💥 Breaking change (fix/feature যা existing functionality break করতে পারে)
- [ ] 📚 Documentation update (README, comments, etc.)
- [ ] 🎨 UI/UX improvements (design changes)
- [ ] ♻️ Refactoring (functional changes নেই)
- [ ] ⚡ Performance improvements
- [ ] ✅ Test related changes
- [ ] 🔧 Build/Configuration changes
- [ ] 🚀 CI/CD related changes

## 🎯 Related Issues

<!-- যদি কোনো issue fix করে থাকেন, তাহলে mention করুন -->

Fixes #(issue number)
Closes #(issue number)

## 📸 Screenshots/Demo

<!-- UI changes থাকলে before/after screenshots add করুন -->

| Before         | After         |
| -------------- | ------------- |
| ![before](url) | ![after](url) |

## 🧪 Testing Checklist

<!-- সব applicable items check করুন -->

- [ ] ✅ Local device এ test করা হয়েছে
- [ ] ✅ Debug build successfully create হচ্ছে
- [ ] ✅ Release build successfully create হচ্ছে
- [ ] ✅ No new warnings বা errors
- [ ] ✅ Existing features break হয়নি
- [ ] ✅ Flutter analyze pass করছে
- [ ] ✅ API connectivity test করা হয়েছে (যদি backend changes থাকে)
- [ ] 📱 বিভিন্ন screen sizes এ test করা হয়েছে

## 📋 Code Quality Checklist

- [ ] 🎯 Code follows project style guidelines
- [ ] 📖 Self-review করা হয়েছে
- [ ] 💬 Complex code এ comments add করা হয়েছে
- [ ] 📚 Documentation update করা হয়েছে (যদি প্রয়োজন হয়)
- [ ] ♻️ Duplicate code এড়ানো হয়েছে
- [ ] 🔒 No sensitive data (API keys, passwords) commit করা হয়নি
- [ ] 🧹 Unused imports/code remove করা হয়েছে

## 🔄 CI/CD Status

<!-- PR create করার পর automatically GitHub Actions run হবে -->

PR merge করার আগে নিশ্চিত করুন:

- [ ] ✅ **Flutter CI** workflow pass করেছে
- [ ] ✅ **Security Scan** কোনো critical issue খুঁজে পায়নি
- [ ] 📦 Build artifacts দেখে verify করেছেন (যদি applicable হয়)

### CI Workflow Triggers:

- ✅ এই PR automatically trigger করবে **Flutter CI** workflow
- ✅ Code analysis, formatting check, এবং tests run হবে
- ✅ Debug APK build হবে এবং artifacts এ upload হবে
- 🔒 Security scan automatically run হবে

## 📦 Build Artifacts

<!-- Merge করার পর `build` branch এ deploy করলে: -->

**Build Branch Deployment:**

- Merge করার পর `build` branch এ push করলে **Android Release Build** workflow trigger হবে
- Release APKs এবং AAB build হবে
- Artifacts 30 days পর্যন্ত available থাকবে

**Testing:**
Reviewers artifacts download করে test করতে পারবেন:

1. PR এর **Checks** tab যান
2. **Flutter CI** workflow details খুলুন
3. **Artifacts** section থেকে debug APK download করুন

## 🚀 Deployment Plan

<!-- Production deploy করার plan থাকলে mention করুন -->

- [ ] 🏷️ Tag create করা হবে (version: `v*.*.* `)
- [ ] 📱 Release APK test করা হবে
- [ ] 📝 Changelog update করা হবে
- [ ] 🎯 Release notes prepare করা আছে

## 📝 Additional Notes

<!-- যেকোনো additional context, concerns, বা questions এখানে লিখুন -->

---

## 👀 Reviewer Notes

<!-- Reviewers এর জন্য specific instructions -->

**Please check:**

- [ ] Code changes logic verify করেছি
- [ ] UI/UX acceptable quality
- [ ] No performance regression
- [ ] Security implications review করেছি
- [ ] CI/CD pipeline successfully pass করেছে

**Special attention required on:**

<!-- যেসব areas এ extra attention দরকার -->

---

### 📚 Additional Resources

- [Project README](../README.md)
- [API Configuration](../lib/config/api_config.dart)
- [CI/CD Workflows](../github/workflows/)
