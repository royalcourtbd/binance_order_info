# Optimal Pricing Calculator - Mathematical Formulas

## 🧮 সম্পূর্ণ Calculation Logic

এই document এ Optimal Pricing Calculator এর সব mathematical formulas বিস্তারিত ব্যাখ্যা করা হয়েছে।

---

## 📐 Core Formulas

### 1. Buy Transaction Analysis

#### A. Received USDT Calculation (Commission বাদে)

```
Received USDT = Crypto Amount - Commission
```

**Example:**

```
Crypto Amount = 10 USDT
Binance Commission = 10 × 0.002 = 0.02 USDT
Received USDT = 10 - 0.02 = 9.98 USDT
```

#### B. Total Cost (Manual Charge সহ)

```
Total Cost (BDT) = Total Price + Manual Charge
```

**Example:**

```
Total Price = 10 × 100 = 1000 BDT
Manual Charge = 5 BDT
Total Cost = 1000 + 5 = 1005 BDT
```

#### C. Actual Buy Rate per USDT

```
Actual Buy Rate = Total Cost (BDT) / Received USDT
```

**Example:**

```
Total Cost = 1005 BDT
Received USDT = 9.98 USDT
Actual Buy Rate = 1005 / 9.98 = 100.70 BDT/USDT
```

---

### 2. Sell Transaction Analysis

#### A. Display Crypto Amount (Commission যোগ করে)

```
Display Crypto Amount = Crypto Amount + Commission
```

**Example:**

```
Crypto Amount = 10 USDT
Binance Commission = 10 × 0.002 = 0.02 USDT
Display Amount = 10 + 0.02 = 10.02 USDT
```

#### B. Total Income (Manual Charge সহ)

```
Total Income (BDT) = Total Price + Manual Charge
```

**Example:**

```
Total Price = 10 × 102 = 1020 BDT
Manual Charge (1.80% buyer markup) = 1020 × 0.0180 = 18.87 BDT
Total Income = 1020 + 18.87 = 1038.87 BDT
```

#### C. Actual Sell Rate per USDT

```
Actual Sell Rate = Total Income (BDT) / Display Crypto Amount
```

**Example:**

```
Total Income = 1038.87 BDT
Display Amount = 10.02 USDT
Actual Sell Rate = 1038.87 / 10.02 = 103.68 BDT/USDT
```

---

### 3. Average Rate Calculations (Weighted Average)

#### A. Average Buy Rate (পুরো মাসের জন্য)

```
Average Buy Rate = Σ(Total Cost of All Buy Transactions) / Σ(Received USDT of All Buy Transactions)
```

**Example with Multiple Transactions:**

```
Transaction 1:
  - Cost = 1005 BDT, Received = 9.98 USDT

Transaction 2:
  - Cost = 5025 BDT, Received = 49.90 USDT

Transaction 3:
  - Cost = 12030 BDT, Received = 99.80 USDT

Total Buy Cost = 1005 + 5025 + 12030 = 18,060 BDT
Total Buy USDT = 9.98 + 49.90 + 99.80 = 159.68 USDT

Average Buy Rate = 18,060 / 159.68 = 113.11 BDT/USDT
```

#### B. Average Sell Rate (পুরো মাসের জন্য)

```
Average Sell Rate = Σ(Total Income of All Sell Transactions) / Σ(Display USDT of All Sell Transactions)
```

**Example with Multiple Transactions:**

```
Transaction 1:
  - Income = 1038.87 BDT, Display = 10.02 USDT

Transaction 2:
  - Income = 5194.35 BDT, Display = 50.10 USDT

Transaction 3:
  - Income = 10400.00 BDT, Display = 100.20 USDT

Total Sell Income = 1038.87 + 5194.35 + 10400.00 = 16,633.22 BDT
Total Sell USDT = 10.02 + 50.10 + 100.20 = 160.32 USDT

Average Sell Rate = 16,633.22 / 160.32 = 103.73 BDT/USDT
```

---

### 4. Profit Calculations

#### A. Current Profit per USDT

```
Current Profit per USDT = Average Sell Rate - Average Buy Rate
```

**Example:**

```
Average Sell Rate = 103.73 BDT/USDT
Average Buy Rate = 113.11 BDT/USDT
Current Profit per USDT = 103.73 - 113.11 = -9.38 BDT/USDT (LOSS!)
```

#### B. Total Current Profit

```
Total Current Profit = Current Profit per USDT × Total Sell USDT
```

**Example:**

```
Current Profit per USDT = -9.38 BDT/USDT
Total Sell USDT = 160.32 USDT
Total Current Profit = -9.38 × 160.32 = -1,503.80 BDT (LOSS!)
```

---

### 5. Optimal Pricing Calculation

#### A. Required Sell Rate for Target Profit

```
Required Sell Rate = Average Buy Rate + Target Profit per USDT
```

**Example:**

```
Average Buy Rate = 113.11 BDT/USDT
Target Profit = 1.00 BDT/USDT
Required Sell Rate = 113.11 + 1.00 = 114.11 BDT/USDT
```

#### B. Expected Total Profit

```
Expected Total Profit = Target Profit per USDT × Expected Sell Quantity
```

**Example:**

```
Target Profit = 1.00 BDT/USDT
Expected Sell Quantity = 100 USDT
Expected Total Profit = 1.00 × 100 = 100.00 BDT
```

#### C. Profit Percentage

```
Profit Percentage = (Target Profit per USDT / Average Buy Rate) × 100
```

**Example:**

```
Target Profit = 1.00 BDT/USDT
Average Buy Rate = 113.11 BDT/USDT
Profit Percentage = (1.00 / 113.11) × 100 = 0.88%
```

---

## 📊 Detailed Example: Full Month Calculation

### Given Data:

**Buy Transactions (January 2026):**

| Order # | USDT | Unit Price | Total BDT | Manual Charge | Commission | Received USDT | Total Cost | Actual Rate |
| ------- | ---- | ---------- | --------- | ------------- | ---------- | ------------- | ---------- | ----------- |
| #12345  | 50   | 120.00     | 6,000     | 5.00          | 0.10       | 49.90         | 6,005      | 120.34      |
| #12346  | 100  | 119.50     | 11,950    | 5.00          | 0.20       | 99.80         | 11,955     | 119.79      |
| #12347  | 75   | 121.00     | 9,075     | 5.00          | 0.15       | 74.85         | 9,080      | 121.32      |
| #12348  | 200  | 120.25     | 24,050    | 5.00          | 0.40       | 199.60        | 24,055     | 120.52      |

**Buy Summary:**

```
Total Buy Cost = 6,005 + 11,955 + 9,080 + 24,055 = 51,095 BDT
Total Buy USDT = 49.90 + 99.80 + 74.85 + 199.60 = 424.15 USDT
Average Buy Rate = 51,095 / 424.15 = 120.48 BDT/USDT
```

**Sell Transactions (January 2026):**

| Order # | USDT | Unit Price | Total BDT | Buyer Markup | Commission | Display USDT | Total Income | Actual Rate |
| ------- | ---- | ---------- | --------- | ------------ | ---------- | ------------ | ------------ | ----------- |
| #23456  | 60   | 121.00     | 7,260     | 134.31       | 0.12       | 60.12        | 7,394.31     | 123.00      |
| #23457  | 80   | 120.75     | 9,660     | 178.71       | 0.16       | 80.16        | 9,838.71     | 122.75      |
| #23458  | 150  | 121.50     | 18,225    | 337.16       | 0.30       | 150.30       | 18,562.16    | 123.52      |

**Sell Summary:**

```
Total Sell Income = 7,394.31 + 9,838.71 + 18,562.16 = 35,795.18 BDT
Total Sell USDT = 60.12 + 80.16 + 150.30 = 290.58 USDT
Average Sell Rate = 35,795.18 / 290.58 = 123.16 BDT/USDT
```

**Current Profit Analysis:**

```
Current Profit per USDT = 123.16 - 120.48 = 2.68 BDT/USDT
Total Current Profit = 2.68 × 290.58 = 778.75 BDT
Profit Percentage = (2.68 / 120.48) × 100 = 2.22%
```

### Optimal Pricing for Target Profit = 1.00 BDT/USDT:

```
Required Sell Rate = 120.48 + 1.00 = 121.48 BDT/USDT
```

**যদি আপনি বাকি USDT বিক্রি করেন:**

```
Remaining USDT = 424.15 - 290.58 = 133.57 USDT

If sold at 121.48 BDT/USDT:
Expected Profit = 1.00 × 133.57 = 133.57 BDT
```

---

## 🔬 Advanced Calculations

### 1. Break-Even Sell Rate

```
Break-Even Rate = Average Buy Rate + 0.00
```

এই rate এ বিক্রি করলে লাভ-লোকসান শূন্য হবে।

### 2. Minimum Profitable Rate

```
Minimum Profitable Rate = Average Buy Rate + 0.01
```

এই rate এ বিক্রি করলে minimum 0.01 BDT/USDT লাভ হবে।

### 3. Maximum Competitive Rate (Market Based)

```
Max Competitive Rate = min(Market Rates of Top 10 Sellers)
```

Market এ যারা sell করছে তাদের মধ্যে সবচেয়ে কম rate।

### 4. Optimal Sweet Spot

```
Optimal Rate = max(Required Sell Rate, Min Competitive Rate - 0.10)
```

যেটা profitable এবং competitive দুটোই।

---

## 📈 Profit Scenarios Table Generation

বিভিন্ন profit targets এর জন্য required rates:

```
For each Target Profit in [0.50, 1.00, 1.50, 2.00, 3.00]:
    Required Rate = Average Buy Rate + Target Profit
    Profit for 100 USDT = Target Profit × 100
    Profit Percentage = (Target Profit / Average Buy Rate) × 100
```

**Example Output:**

| Target Profit | Required Rate | Profit (100 USDT) | Profit % |
| ------------- | ------------- | ----------------- | -------- |
| ৳0.50         | 120.98        | ৳50.00            | 0.41%    |
| ৳1.00         | 121.48        | ৳100.00           | 0.83%    |
| ৳1.50         | 121.98        | ৳150.00           | 1.24%    |
| ৳2.00         | 122.48        | ৳200.00           | 1.66%    |
| ৳3.00         | 123.48        | ৳300.00           | 2.49%    |

---

## 🎯 Validation & Edge Cases

### 1. Zero Buy Transactions

```
if (totalBuyUsdt == 0):
    avgBuyRate = 0.0
    requiredSellRate = 0.0 + targetProfit
    // Will show as 0.00 in UI, handled gracefully
```

### 2. Zero Sell Transactions

```
if (totalSellUsdt == 0):
    avgSellRate = 0.0
    currentProfit = 0.0
    // Only buy rate is calculated, which is fine
```

### 3. Negative Profit (Current Loss)

```
if (avgSellRate < avgBuyRate):
    currentProfit = negative value
    // Displayed in red color in UI
```

### 4. Very Large Quantities

```
// Using double precision (64-bit)
// Can handle up to 10^15 BDT and USDT
// Enough for all practical P2P trading scenarios
```

---

## 🔍 Implementation Notes

### Precision:

- All calculations use `double` (64-bit floating point)
- Display rounded to 2 decimal places
- Internal calculations maintain full precision

### Rounding Strategy:

- Display values: `toStringAsFixed(2)`
- No rounding during intermediate calculations
- Final result rounded only for display

### Weighted Average Rationale:

- Simple average of rates would be incorrect
- Example:

  ```
  Transaction 1: 10 USDT @ 120 BDT = 1200 BDT
  Transaction 2: 100 USDT @ 100 BDT = 10000 BDT

  Wrong (Simple Avg): (120 + 100) / 2 = 110 BDT/USDT
  Correct (Weighted): (1200 + 10000) / (10 + 100) = 101.82 BDT/USDT
  ```

### Performance:

- All calculations happen in-memory
- No API calls for calculation
- Instant results even with 100+ transactions
- O(n) complexity where n = number of transactions

---

## 🧪 Test Cases

### Test Case 1: Simple Single Transaction

```
Input:
  - Buy: 100 USDT @ 120 BDT = 12,000 BDT, Manual Charge = 5 BDT
  - Commission: 0.2 USDT
  - Target Profit: 1.00 BDT/USDT

Expected Output:
  - Received: 99.8 USDT
  - Total Cost: 12,005 BDT
  - Average Buy Rate: 12,005 / 99.8 = 120.29 BDT/USDT
  - Required Sell Rate: 120.29 + 1.00 = 121.29 BDT/USDT
```

### Test Case 2: Multiple Transactions with Different Rates

```
Input:
  - Buy 1: 50 USDT @ 120 BDT, Charge = 5
  - Buy 2: 100 USDT @ 115 BDT, Charge = 5
  - Target: 1.50 BDT/USDT

Expected Output:
  - Average Buy Rate: ≈ 116.73 BDT/USDT (weighted)
  - Required Sell Rate: 116.73 + 1.50 = 118.23 BDT/USDT
```

### Test Case 3: No Buy Transactions

```
Input:
  - No buy transactions
  - Target: 1.00 BDT/USDT

Expected Output:
  - Average Buy Rate: 0.00
  - Required Sell Rate: 0.00
  - UI shows "কোনো transaction data পাওয়া যায়নি"
```

---

## 📚 References

### Binance P2P Fee Structure:

- Maker Fee: 0% (Free)
- Taker Fee: 0.2% (The person accepting the ad pays)
- Source: Binance Official Documentation

### BDT Exchange Rate:

- Variable, depends on market
- Typically 118-125 BDT per USDT
- Updated real-time in the app

---

## ✅ Formula Verification Checklist

- [x] Buy rate calculation includes all fees
- [x] Sell rate calculation includes buyer markup
- [x] Weighted average used for multiple transactions
- [x] Manual charges properly added
- [x] Commission correctly subtracted/added
- [x] Profit calculation matches expected results
- [x] Edge cases handled gracefully
- [x] Precision maintained throughout
- [x] Display rounding applied correctly

---

## 🎓 Mathematical Proof

### Proof: Required Sell Rate Formula

**Given:**

- Average Buy Rate = B (BDT/USDT)
- Target Profit per USDT = P (BDT/USDT)
- Required Sell Rate = S (BDT/USDT)
- Quantity to Sell = Q (USDT)

**To Prove:**

```
S = B + P
```

**Proof:**

```
Total Cost to Buy Q USDT = B × Q
Target Total Profit = P × Q
Required Total Income = Total Cost + Target Profit
Required Total Income = (B × Q) + (P × Q)
Required Total Income = (B + P) × Q

Sell Rate S = Required Total Income / Q
S = (B + P) × Q / Q
S = B + P

Q.E.D.
```

---

_এই document টি Optimal Pricing Calculator এর সম্পূর্ণ mathematical foundation প্রদান করে।_

_Version: 1.0_
_Last Updated: January 2026_
