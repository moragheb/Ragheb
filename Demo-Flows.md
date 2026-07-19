# CIP Integration Agent Demo Flows

## Demo 1: Sync FO Product Catalog (Guide Me Mode)

```mermaid
flowchart LR
	subgraph Trigger["🕐 HTTP Trigger"]
		HTTP["HTTP Request<br/>ProductCatalogSyncRequest"]
	end

	subgraph CIP1["CIP-2010<br/>SyncFoProductCatalog<br/><b>Built in</b>"]
		direction TB
		Process1["Process with<br/>Input & Output Models"]
		Step1["Step 10:<br/>Fetch Products"]
		Step2["Step 20:<br/>Send to SB"]
	end

	subgraph GenericDep1["CIP-2011<br/>GetFoCustomerGroups"]
		Generic1["GetFromFoHttp<br/><b>Generic Process</b>"]
	end

	subgraph GenericDep2["CIP-2012<br/>SendProductsToSB"]
		Generic2["SendToServiceBus<br/><b>Generic Process</b>"]
	end

	subgraph External1["F&O"]
		FO1["GET /data/Products<br/>?$top=1000"]
	end

	subgraph External2["Service Bus"]
		SB1["Topic:<br/>product-catalog-sync"]
	end

	HTTP -->|"Triggers"| CIP1
	CIP1 -->|"Calls Dependency"| GenericDep1
	GenericDep1 -->|"HTTP GET"| FO1
	FO1 -.->|"Product Data JSON"| GenericDep1
	GenericDep1 -.->|"Stream"| CIP1
	CIP1 -->|"Calls Dependency"| GenericDep2
	GenericDep2 -->|"Publish Message"| SB1
	SB1 -.->|"Ack"| GenericDep2
	GenericDep2 -.->|"Success"| CIP1
	CIP1 -.->|"SyncProductCatalogResult"| HTTP

	style CIP1 fill:#0055A4,color:#fff,stroke:#003d7a
	style GenericDep1 fill:#0055A4,color:#fff,stroke:#003d7a
	style GenericDep2 fill:#0055A4,color:#fff,stroke:#003d7a
	style External1 fill:#999,color:#fff,stroke:#666
	style External2 fill:#999,color:#fff,stroke:#666
	style Trigger fill:#fff,color:#000,stroke:#000
```

### Key Features
- ✅ **Input Model**: `ProductCatalogSyncRequest` (category filter, modified date, max records)
- ✅ **Output Model**: `SyncProductCatalogResult` (count, timestamp, success, message)
- ✅ **Generic Processes**: GetFromFoHttp, SendToServiceBus
- ✅ **Environments**: dev, uat, prod

---

## Demo 2: Handle Customer Data Validation (Ask Me Everything Mode)

```mermaid
flowchart LR
	subgraph Trigger2["📨 Service Bus Trigger"]
		SBT["Service Bus Message<br/>CustomerDataMessage"]
	end

	subgraph CIP2["CIP-2020<br/>HandleCustomerDataValidation<br/><b>Built in</b>"]
		direction TB
		Process2["ServiceBusTriggerBaseProcess"]
		Step21["Step 10:<br/>Validate Customer"]
		Step22["Step 20:<br/>Send to SB"]
	end

	subgraph CustomDep["CIP-2021<br/>CustomerValidationService<br/><b>Requirement Specific</b>"]
		direction TB
		Custom["DependencyHttpRequestProcess<br/>HttpConnectedSystem.Dataverse"]
		Details["POST /api/v1/customers/validate<br/>Retries: 3, Interval: 5s"]
	end

	subgraph GenericDep3["CIP-2022<br/>SendValidatedData"]
		Generic3["SendToServiceBus<br/><b>Generic Process</b>"]
	end

	subgraph External3["Dataverse"]
		DV["Customer Validation API<br/>POST /api/v1/customers/validate"]
	end

	subgraph External4["Service Bus"]
		SB2["Topic: customer-orders-topic<br/>Subscription: cip-order-processor"]
	end

	SBT -->|"Triggers"| CIP2
	CIP2 -->|"Calls Custom Dependency"| CustomDep
	CustomDep -->|"HTTP POST<br/>(Email, Phone, Address)"| DV
	DV -.->|"Validation Result JSON"| CustomDep
	CustomDep -.->|"Stream"| CIP2
	CIP2 -->|"Calls Dependency"| GenericDep3
	GenericDep3 -->|"Publish Validated Data"| SB2
	SB2 -.->|"Ack"| GenericDep3
	GenericDep3 -.->|"Success"| CIP2
	CIP2 -.->|"Complete Message"| SBT

	style CIP2 fill:#0055A4,color:#fff,stroke:#003d7a
	style CustomDep fill:#008B8B,color:#fff,stroke:#006666
	style GenericDep3 fill:#0055A4,color:#fff,stroke:#003d7a
	style External3 fill:#999,color:#fff,stroke:#666
	style External4 fill:#999,color:#fff,stroke:#666
	style Trigger2 fill:#fff,color:#000,stroke:#000
```

### Key Features
- ✅ **Custom Dependency Class**: `CustomerValidationService` extends `DependencyHttpRequestProcess`
- ✅ **Connected System**: HttpConnectedSystem.Dataverse
- ✅ **HTTP Method**: POST to `/api/v1/customers/validate`
- ✅ **Input Model**: `CustomerDataMessage` (CustomerId, Email, Phone, Address)
- ✅ **Q14-Q19 Flow**: Custom dependency instead of generic process
- ✅ **Environments**: dev, uat

---

## Demo 3: Process Inventory Adjustments Batch (Pre-Filled Form Mode)

```mermaid
flowchart LR
	subgraph Trigger3["⏰ Timer Trigger"]
		Timer["Timer Schedule<br/>(Cron Expression)"]
	end

	subgraph CIP3["CIP-2030<br/>ProcessInventoryAdjustments<br/><b>Built in</b>"]
		direction TB
		Process3["IntegrationBaseProcess<br/>Multi-Step Orchestration"]
		Step31["Step 10: Fetch Adjustments"]
		Step32["Step 20: Validate Schema"]
		Step33["Step 30: Transform for ERP"]
		Step34["Step 40: Batch Send"]
	end

	subgraph GenericDep4["CIP-2031<br/>GetInventoryAdjustments"]
		Generic4["GetFromFoHttp<br/><b>Generic Process</b>"]
	end

	subgraph StubDep1["CIP-2032<br/>ValidateInventorySchema<br/><b>⚠️ STUB - One Time Setup</b>"]
		direction TB
		Stub1["IntegrationBaseProcess"]
		StubDetails1["❌ NotImplementedException<br/>TODO: Implement schema validation"]
	end

	subgraph StubDep2["CIP-2033<br/>TransformToErpFormat<br/><b>⚠️ STUB - One Time Setup</b>"]
		direction TB
		Stub2["IntegrationBaseProcess"]
		StubDetails2["❌ NotImplementedException<br/>TODO: Implement ERP transformation"]
	end

	subgraph GenericDep5["CIP-2034<br/>BatchSendAdjustments"]
		Generic5["SendBatchToServiceBus<br/><b>Generic Process</b>"]
	end

	subgraph External5["F&O"]
		FO2["GET /data/InventoryAdjustmentJournals<br/>?$filter=Status eq 'Pending'"]
	end

	subgraph External6["Service Bus"]
		SB3["Queue:<br/>inventory-adjustments-queue"]
	end

	Timer -->|"Triggers"| CIP3
	CIP3 -->|"Step 10"| GenericDep4
	GenericDep4 -->|"HTTP GET"| FO2
	FO2 -.->|"Adjustment Records JSON"| GenericDep4
	GenericDep4 -.->|"Stream"| CIP3

	CIP3 -->|"Step 20"| StubDep1
	StubDep1 -.->|"⚠️ Throws Exception<br/>(Until Implemented)"| CIP3

	CIP3 -->|"Step 30"| StubDep2
	StubDep2 -.->|"⚠️ Throws Exception<br/>(Until Implemented)"| CIP3

	CIP3 -->|"Step 40"| GenericDep5
	GenericDep5 -->|"Batch Publish"| SB3
	SB3 -.->|"Ack"| GenericDep5
	GenericDep5 -.->|"Success"| CIP3

	style CIP3 fill:#0055A4,color:#fff,stroke:#003d7a
	style GenericDep4 fill:#0055A4,color:#fff,stroke:#003d7a
	style GenericDep5 fill:#0055A4,color:#fff,stroke:#003d7a
	style StubDep1 fill:#FFD700,color:#000,stroke:#FFA500
	style StubDep2 fill:#FFD700,color:#000,stroke:#FFA500
	style External5 fill:#999,color:#fff,stroke:#666
	style External6 fill:#999,color:#fff,stroke:#666
	style Trigger3 fill:#fff,color:#000,stroke:#000
```

### Key Features
- ✅ **4-Step Orchestration**: Fetch → Validate → Transform → Send
- ✅ **2 Stubs Scaffolded**: ValidateInventorySchema, TransformToErpFormat
- ✅ **2 Working Processes**: GetFromFoHttp, SendBatchToServiceBus
- ✅ **Timer Trigger**: No input model required
- ✅ **Multi-Environment Config**: dev, uat, prod (9 JSON files)
- ⚠️ **Stubs compile but throw NotImplementedException** until implemented

---

## Legend

| Color | Meaning |
|-------|---------|
| 🔵 **Blue** | Built-in CIP Integration Process |
| 🟢 **Teal** | Requirement-Specific (Custom Dependency) |
| 🟡 **Yellow** | Stub / One-Time Generic Process Setup |
| ⚪ **Gray** | External System (F&O, Dataverse, Service Bus) |

| Line Type | Meaning |
|-----------|---------|
| **Solid Arrow** | Synchronous Call / Flow |
| **Dashed Arrow** | Response / Callback |

---

## Summary Comparison

| Feature | Demo 1 | Demo 2 | Demo 3 |
|---------|--------|--------|--------|
| **Trigger** | HTTP | Service Bus | Timer |
| **Input Model** | ✅ ProductCatalogSyncRequest | ✅ CustomerDataMessage | ❌ none |
| **Output Model** | ✅ SyncProductCatalogResult | ❌ none | ❌ none |
| **Custom Dependency** | ❌ | ✅ CustomerValidationService | ❌ |
| **Generic Processes** | 2 | 1 | 2 |
| **Stubs** | 0 | 0 | 2 |
| **Steps** | 2 | 2 | 4 |
| **Environments** | 3 (dev, uat, prod) | 2 (dev, uat) | 3 (dev, uat, prod) |
| **Files Generated** | 13 | 9 | 15 |

---

## Integration Type Allocations

### Demo 1 (CIP-2010 series)
- **CIP-2010**: SyncFoProductCatalog
- **CIP-2011**: GetFoCustomerGroups (dependency)
- **CIP-2012**: SendProductsToSB (dependency)

### Demo 2 (CIP-2020 series)
- **CIP-2020**: HandleCustomerDataValidation
- **CIP-2021**: CustomerValidationService (custom dependency)
- **CIP-2022**: SendValidatedData (dependency)

### Demo 3 (CIP-2030 series)
- **CIP-2030**: ProcessInventoryAdjustments
- **CIP-2031**: GetInventoryAdjustments (dependency)
- **CIP-2032**: ValidateInventorySchema (stub)
- **CIP-2033**: TransformToErpFormat (stub)
- **CIP-2034**: BatchSendAdjustments (dependency)
