# modelDataCarRent

# Five Data Models for Car Availability in DynamoDB

### **Model 1: Delegation + Car + Date Map**  
- **Structure:**  
  - **PK** = `DELEGATION`, **SK** = `CAR`, `dates` = `{YYYY/MM/DD: boolean}`.  
- **Advantages:**  
  - Simple per-car storage.  
- **Disadvantages:**  
  - Wasted space storing `false` values.  
  - Inefficient date-range queries.  

### **Model 2: Delegation + Calendar + Date List**  
- **Structure:**  
  - **PK** = `DELEGATION`, **SK** = `CALENDAR`, `dates` = `[YYYY/MM/DD]` (one item per car).  
- **Advantages:**  
  - Dedicated calendar entity.  
- **Disadvantages:**  
  - Redundant PK/SK design.  
  - Harder to query cars directly.  

### **Model 3: Delegation + Car + Date Set (Your Choice)**  
- **Structure:**  
  - **PK** = `DELEGATION`, **SK** = `CAR`, `availableDates` = `{YYYY/MM/DD}` (set).  
- **Advantages:**  
  - No wasted storage (only tracks *available* dates).  
  - Simple per-car access.  
- **Disadvantages:**  
  - Requires GSI for date-based queries (e.g., "find cars free on 2025/06/10").  

### **Model 4: Date-Partitioned + Car List**  
- **Structure:**  
  - **PK** = `DATE#YYYY/MM/DD`, **SK** = `CAR`, with car attributes duplicated per date.  
- **Advantages:**  
  - Blazing-fast date-based queries.  
- **Disadvantages:**  
  - High data duplication.  
  - Complex updates (e.g., car price changes).  

### **Model 5: Car + Date Ranges**  
- **Structure:**  
  - **PK** = `CAR`, **SK** = `DELEGATION`, `availability` = `[{start: YYYY/MM/DD, end: ...}]`.  
- **Advantages:**  
  - Handles date ranges (e.g., weekly blocks).  
  - Reduces item count.  
- **Disadvantages:**  
  - Complex logic to check specific dates.  
  - Overlaps can cause bugs.  

---  

### **Why Model 3 Is Best for DynamoDB Beginners**  
✅ **Simplicity:** One item per car—natural fit for CRUD operations and way easier to understand for me.  
✅ **Storage Efficiency:** Only stores *available* dates (no wasted `false` flags).  
✅ **Scalability:** Avoids redundant PK/SK designs and write-heavy duplication.  
✅ **Future Flexibility:** Start simple, add a GSI later if needed for date queries.  

