CREATE TABLE [dbo].[tblROIUserFilter]
(
[Rec_Id] [int] NOT NULL IDENTITY(1, 1),
[UserKey] [int] NOT NULL,
[CompanyKey] [int] NULL,
[Policy_Opportunities] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Policy_Opportunities] DEFAULT ((0)),
[Negotiated_Discounts] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Negotiated_Discounts] DEFAULT ((0)),
[Loyalty_Awards] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Loyalty_Awards] DEFAULT ((0)),
[Payment_Rebate] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Payment_Rebate] DEFAULT ((0)),
[Online_Adoption] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Online_Adoption] DEFAULT ((0)),
[Web_Fares] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Web_Fares] DEFAULT ((0)),
[Waiver_Favors] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Waiver_Favors] DEFAULT ((0)),
[Prepaid_Travel] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Prepaid_Travel] DEFAULT ((0)),
[Audit_Searches] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Audit_Searches] DEFAULT ((0)),
[Agency_Discount] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Agency_Discount] DEFAULT ((0)),
[PreTrip_Approval] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_PreTrip_Approval] DEFAULT ((0)),
[Lost_Tickets] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Lost_Tickets] DEFAULT ((0)),
[Exchanges] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Exchanges] DEFAULT ((0)),
[Refunds] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Refunds] DEFAULT ((0)),
[Voids] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Voids] DEFAULT ((0)),
[Banked_Tickets] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_Banked_Tickets] DEFAULT ((0)),
[IsActive] [bit] NULL CONSTRAINT [DF_tblROIUserFilter_IsActive] DEFAULT ((0)),
[Created_By] [int] NULL,
[Created_On] [datetime] NULL,
[Modified_By] [int] NULL,
[Modified_On] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblROIUserFilter] ADD CONSTRAINT [PK_tblROIUserFilter] PRIMARY KEY CLUSTERED  ([Rec_Id]) ON [PRIMARY]
GO
