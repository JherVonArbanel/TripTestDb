SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Sunil K>
-- Create date: <30th Aug 18>
-- Description:	<To Update into Trip related Tables>
-- declare @xmldata xml = N'<UpdatePurchasedTrip><TripPassenger><TripPassengerInfos><TripPassengerInfo><ReimbursementAddressId>0</ReimbursementAddressId><TripHistoryKey>00000000-0000-0000-0000-000000000000</TripHistoryKey><PassengerKey>0</PassengerKey><PassengerTypeKey>1</PassengerTypeKey><IsPrimaryPassenger>True</IsPrimaryPassenger><AdditionalRequest></AdditionalRequest><PassengerEmailID>SHYAMCA2016@GMAIL.COM</PassengerEmailID><PassengerFirstName>ASHYAMALA</PassengerFirstName><PassengerLastName>GANESAMOORTHY</PassengerLastName><PassengerLocale></PassengerLocale><PassengerTitle></PassengerTitle><PassengerGender></PassengerGender><PassengerBirthDate>01/01/0001 00:00:00</PassengerBirthDate><TravelReferenceNo>1.1</TravelReferenceNo><TripRequestKey>0</TripRequestKey><IsExcludePricingInfo>false</IsExcludePricingInfo><PassengerKey>0</PassengerKey><TripPassengerCreditCardInfos><TripPassengerCreditCardInfo><TripTypeComponent>0</TripTypeComponent><CreditCardKey>0</CreditCardKey><creditCardVendorCode>VI</creditCardVendorCode><creditCardDescription></creditCardDescription><creditCardLastFourDigit>1111</creditCardLastFourDigit><expiryMonth>8</expiryMonth><expiryYear>25</expiryYear><TripPassengerInfoKey>0</TripPassengerInfoKey><NameOnCard>GANESAMOORTHY</NameOnCard><UsedforAir>0</UsedforAir><UsedforHotel>1</UsedforHotel><UsedforCar>0</UsedforCar><creditCardTypeKey>0</creditCardTypeKey></TripPassengerCreditCardInfo></TripPassengerCreditCardInfos><TripPassengerPreferences><TripPassengerAirPreference><PassengerKey>0</PassengerKey><ID>0</ID><OriginAirportCode></OriginAirportCode><TicketDelivery></TicketDelivery><AirSeatingType>0</AirSeatingType><AirRowType>0</AirRowType><AirMealType>1</AirMealType><AirSpecialSevicesType>0</AirSpecialSevicesType><TripPassengerAirVendorPreferences /></TripPassengerAirPreference><TripPassengerHotelPreference><PassengerKey>0</PassengerKey><ID>0</ID><SmokingType>0</SmokingType><BedType>0</BedType><TripPassengerHotelVendorPreferences /></TripPassengerHotelPreference><TripPassengerCarPreference><PassengerKey>0</PassengerKey><ID>0</ID><TripPassengerCarVendorPreferences /></TripPassengerCarPreference></TripPassengerPreferences><TripPassengerUDIDInfos><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>20</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>CHECK</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>6</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>PRODUCTION</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>83</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>O</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>300</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>SHYAMCA2016.AT.GMAIL.COM</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>14</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>TEST GROUP</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>17</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>A GANESAMOORTHY</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>15</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>ASHYAMALA GANESAMOORTHY</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>17</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>A</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>12</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>411.4</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>148</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>A</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>18</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>AHC POLICY</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>209</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>A0GLV5</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>262</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>45737123</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>141</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>A</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>142</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>109.39</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>143</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>109.39</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>144</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>109.39</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>145</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>RAC</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>165</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>A</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>166</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>94.00</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>167</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>94.00</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>168</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>94.00</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>169</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>NEG</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>189</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>C</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>278</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>N</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>410</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>1979</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>16</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>A</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>76</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>SABRE</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>288</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>Y</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>70</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>0</UserID><PassengerUDIDValue>0167176193413</PassengerUDIDValue></TripPassengerUDIDInfo></TripPassengerUDIDInfos></TripPassengerInfo></TripPassengerInfos></TripPassenger><TripComponents><Air><TripAirPrices><TripAirPrice><tripCategory>Actual</tripCategory><tripAdultBase>356.28</tripAdultBase><tripAdultTax>55.12</tripAdultTax><tripSeniorBase>0</tripSeniorBase><tripSeniorTax>0</tripSeniorTax><tripYouthBase>0</tripYouthBase><tripYouthTax>0</tripYouthTax><tripChildBase>0</tripChildBase><tripChildTax>0</tripChildTax><tripInfantBase>0</tripInfantBase><tripInfantTax>0</tripInfantTax><tripInfantWithSeatBase>0</tripInfantWithSeatBase><tripInfantWithSeatTax>0</tripInfantWithSeatTax><tripAirResponseTaxes><tripAirResponseTax><amount>26.72</amount><designator>US</designator><nature></nature><description></description></tripAirResponseTax><tripAirResponseTax><amount>8.2</amount><designator>ZP</designator><nature></nature><description></description></tripAirResponseTax><tripAirResponseTax><amount>11.2</amount><designator>AY</designator><nature></nature><description></description></tripAirResponseTax><tripAirResponseTax><amount>9</amount><designator>XF</designator><nature></nature><description></description></tripAirResponseTax></tripAirResponseTaxes><ValidatingCarriers>null</ValidatingCarriers><NewBookingClasses>null</NewBookingClasses><TickettingEntryCount>0</TickettingEntryCount><RepricedEntries>null</RepricedEntries><isCabinReprice>False</isCabinReprice></TripAirPrice><TripAirPrice><tripCategory>Search</tripCategory><tripAdultBase>0</tripAdultBase><tripAdultTax>0</tripAdultTax><tripSeniorBase>0</tripSeniorBase><tripSeniorTax>0</tripSeniorTax><tripYouthBase>0</tripYouthBase><tripYouthTax>0</tripYouthTax><tripChildBase>0</tripChildBase><tripChildTax>0</tripChildTax><tripInfantBase>0</tripInfantBase><tripInfantTax>0</tripInfantTax><tripInfantWithSeatBase>0</tripInfantWithSeatBase><tripInfantWithSeatTax>0</tripInfantWithSeatTax><ValidatingCarriers>null</ValidatingCarriers><NewBookingClasses>null</NewBookingClasses><TickettingEntryCount>0</TickettingEntryCount><RepricedEntries>null</RepricedEntries><isCabinReprice>False</isCabinReprice></TripAirPrice></TripAirPrices><TripAirResponse><searchAirPrice>0</searchAirPrice><searchAirTax>0</searchAirTax><actualAirPrice>356.28</actualAirPrice><actualAirTax>55.12</actualAirTax><bookingcharges>0</bookingcharges><appliedDiscount>0</appliedDiscount><repricedAirPrice>0</repricedAirPrice><repricedAirTax>0</repricedAirTax><CurrencyCodeKey>USD</CurrencyCodeKey><isSplit>False</isSplit><agentWareQueryID></agentWareQueryID><agentwareItineraryID></agentwareItineraryID><redeemPoints>0</redeemPoints><redeemAuthNumber></redeemAuthNumber><TripAirLegs><TripAirSegments><TripAirLeg><gdsSourceKey>2</gdsSourceKey><selectedBrand></selectedBrand><recordLocator></recordLocator><airLegNumber>1</airLegNumber><validatingCarrier>UA</validatingCarrier><contractCode></contractCode><isRefundable>False</isRefundable><TripAirLegPassengerInfos><TripAirLegPassengerInfo><PassengerKey>0</PassengerKey><ticketNumber>0167176193413</ticketNumber><InvoiceNumber>0575293</InvoiceNumber></TripAirLegPassengerInfo></TripAirLegPassengerInfos></TripAirLeg><TripAirSegment><airSegmentKey>e75ecc73-3bb1-44fa-9520-db4914cb4e4c</airSegmentKey><airLegNumber>1</airLegNumber><airSegmentMarketingAirlineCode>UA</airSegmentMarketingAirlineCode><airSegmentOperatingAirlineCode>UA</airSegmentOperatingAirlineCode><airSegmentFlightNumber>237</airSegmentFlightNumber><airSegmentDuration>02:10:00</airSegmentDuration><airSegmentEquipment>319</airSegmentEquipment><airSegmentMiles>643</airSegmentMiles><airSegmentDepartureDate>03/16/2019 06:05:00</airSegmentDepartureDate><airSegmentArrivalDate>03/16/2019 07:15:00</airSegmentArrivalDate><airSegmentDepartureAirport>DFW</airSegmentDepartureAirport><airSegmentArrivalAirport>DEN</airSegmentArrivalAirport><airSegmentResBookDesigCode>L</airSegmentResBookDesigCode><airSegmentDepartureOffset>-6</airSegmentDepartureOffset><airSegmentArrivalOffset>-7</airSegmentArrivalOffset><airSegmentSeatRemaining>0</airSegmentSeatRemaining><airSegmentMarriageGrp>UA</airSegmentMarriageGrp><airFareBasisCode></airFareBasisCode><airFareReferenceKey></airFareReferenceKey><airSelectedSeatNumber></airSelectedSeatNumber><seatMapStatus></seatMapStatus><airsegmentcabin></airsegmentcabin><ticketNumber></ticketNumber><airSegmentOperatingFlightNumber></airSegmentOperatingFlightNumber><RecordLocator>N7C2HX</RecordLocator><RPH>1</RPH><airSegmentOperatingAirlineCompanyShortName>Ua</airSegmentOperatingAirlineCompanyShortName><DepartureTerminal>TERMINAL E</DepartureTerminal><ArrivalTerminal></ArrivalTerminal><PNRNo></PNRNo><airSegmentBrandName></airSegmentBrandName><airSegmentFareCategory></airSegmentFareCategory><TripAirSegmentPassengersInfo><TripAirSegmentPassengerInfo><PassengerKey>0</PassengerKey><airFareBasisCode></airFareBasisCode><airSelectedSeatNumber></airSelectedSeatNumber><seatMapStatus></seatMapStatus></TripAirSegmentPassengerInfo></TripAirSegmentPassengersInfo></TripAirSegment></TripAirSegments><TripAirSegments><TripAirLeg><gdsSourceKey>2</gdsSourceKey><selectedBrand></selectedBrand><recordLocator></recordLocator><airLegNumber>2</airLegNumber><validatingCarrier>UA</validatingCarrier><contractCode></contractCode><isRefundable>False</isRefundable><TripAirLegPassengerInfos><TripAirLegPassengerInfo><PassengerKey>0</PassengerKey><ticketNumber>0167176193413</ticketNumber><InvoiceNumber>0575293</InvoiceNumber></TripAirLegPassengerInfo></TripAirLegPassengerInfos></TripAirLeg><TripAirSegment><airSegmentKey>3beb65bf-8c69-4c56-88a9-bb60d14ae4f7</airSegmentKey><airLegNumber>2</airLegNumber><airSegmentMarketingAirlineCode>UA</airSegmentMarketingAirlineCode><airSegmentOperatingAirlineCode>UA</airSegmentOperatingAirlineCode><airSegmentFlightNumber>469</airSegmentFlightNumber><airSegmentDuration>01:50:00</airSegmentDuration><airSegmentEquipment>319</airSegmentEquipment><airSegmentMiles>643</airSegmentMiles><airSegmentDepartureDate>03/17/2019 12:35:00</airSegmentDepartureDate><airSegmentArrivalDate>03/17/2019 15:25:00</airSegmentArrivalDate><airSegmentDepartureAirport>DEN</airSegmentDepartureAirport><airSegmentArrivalAirport>DFW</airSegmentArrivalAirport><airSegmentResBookDesigCode>U</airSegmentResBookDesigCode><airSegmentDepartureOffset>-7</airSegmentDepartureOffset><airSegmentArrivalOffset>-6</airSegmentArrivalOffset><airSegmentSeatRemaining>0</airSegmentSeatRemaining><airSegmentMarriageGrp>UA</airSegmentMarriageGrp><airFareBasisCode></airFareBasisCode><airFareReferenceKey></airFareReferenceKey><airSelectedSeatNumber></airSelectedSeatNumber><seatMapStatus></seatMapStatus><airsegmentcabin></airsegmentcabin><ticketNumber></ticketNumber><airSegmentOperatingFlightNumber></airSegmentOperatingFlightNumber><RecordLocator>N7C2HX</RecordLocator><RPH>4</RPH><airSegmentOperatingAirlineCompanyShortName>Ua</airSegmentOperatingAirlineCompanyShortName><DepartureTerminal></DepartureTerminal><ArrivalTerminal>TERMINAL E</ArrivalTerminal><PNRNo></PNRNo><airSegmentBrandName></airSegmentBrandName><airSegmentFareCategory></airSegmentFareCategory><TripAirSegmentPassengersInfo><TripAirSegmentPassengerInfo><PassengerKey>0</PassengerKey><airFareBasisCode></airFareBasisCode><airSelectedSeatNumber></airSelectedSeatNumber><seatMapStatus></seatMapStatus></TripAirSegmentPassengerInfo></TripAirSegmentPassengersInfo></TripAirSegment></TripAirSegments></TripAirLegs></TripAirResponse></Air><Hotel><TripHotelResponse><HotelResponseKey>fe86afe4-8d64-4edc-8b30-c1b5abac1cb4</HotelResponseKey><supplierHotelKey>4884</supplierHotelKey><supplierId>Sabre</supplierId><minRate>0</minRate><minRateTax>0</minRateTax><hotelDailyPrice>94</hotelDailyPrice><hotelDescription></hotelDescription><hotelRatePlanCode>A0GLV5</hotelRatePlanCode><hotelTotalPrice>94</hotelTotalPrice><hotelPriceType>0</hotelPriceType><hotelTaxRate>0</hotelTaxRate><rateDescription></rateDescription><guaranteeCode>G</guaranteeCode><SearchHotelPrice>94</SearchHotelPrice><searchHotelTax>0</searchHotelTax><actualHotelPrice>94</actualHotelPrice><actualHotelTax>0</actualHotelTax><checkInDate>03/16/2019 00:00:00</checkInDate><checkOutDate>03/17/2019 00:00:00</checkOutDate><recordLocator>AFWAIL</recordLocator><CurrencyCodeKey>USD</CurrencyCodeKey><PolicyReasonCodeId>0</PolicyReasonCodeId><HotelPolicyKey>0</HotelPolicyKey><roomAmenities></roomAmenities><cancellationPolicy></cancellationPolicy><checkInInstruction></checkInInstruction><hotelCheckInTime></hotelCheckInTime><hotelCheckOutTime></hotelCheckOutTime><vendorCode>HG</vendorCode><cityCode>DEN</cityCode><HotelPolicy></HotelPolicy><yieldManagementValueKey>0</yieldManagementValueKey><SupplierType></SupplierType><perPersonDailyBaseCost>94</perPersonDailyBaseCost><perPersonDailyTotal>94</perPersonDailyTotal><hotelRoomTypeCode>A0GLV5</hotelRoomTypeCode><preferenceOrder>4</preferenceOrder><contractCode></contractCode><salesAndOccupancyTax>0</salesAndOccupancyTax><originalHotelTotalPrice>0</originalHotelTotalPrice><RPH>3</RPH><InvoiceNumber></InvoiceNumber><roomDescriptionShort></roomDescriptionShort><MarketplaceMarginPercent>0</MarketplaceMarginPercent><estimatedRefundAmount>0</estimatedRefundAmount><IsPromoTrue>False</IsPromoTrue><PromoDescription></PromoDescription><PromoId></PromoId><AverageBaseRate>0</AverageBaseRate><DepositAmount>0</DepositAmount><HotelId></HotelId></TripHotelResponse><HotelSupplierId>4884</HotelSupplierId><Phone>1-303-706-0102</Phone><TripHotelResponsePassengerInfos><TripHotelResponsePassengerInfo><HotelResponseKey>fe86afe4-8d64-4edc-8b30-c1b5abac1cb4</HotelResponseKey><TripPassengerInfoKey>0</TripPassengerInfoKey><confirmationNumber>80142405-</confirmationNumber><ItineraryNumber></ItineraryNumber></TripHotelResponsePassengerInfo></TripHotelResponsePassengerInfos></Hotel><Car><TripCarResponse><carResponseKey>1bbece02-a617-4590-87a4-a058bfec31a1</carResponseKey><carVendorKey>ZE</carVendorKey><supplierId>Sabre</supplierId><carCategoryCode>PCAR</carCategoryCode><carLocationCode>DEN</carLocationCode><carLocationCategoryCode>DEN</carLocationCategoryCode><carDropOffLocationCode>DEN</carDropOffLocationCode><carDropOffLocationCategoryCode>DEN</carDropOffLocationCategoryCode><minRate>109.39</minRate><minRateTax>68.15</minRateTax><DailyRate>0</DailyRate><TotalChargeAmt>0</TotalChargeAmt><NoOfDays>0</NoOfDays><SearchCarPrice>109.39</SearchCarPrice><searchCarTax>68.15</searchCarTax><actualCarPrice>109.39</actualCarPrice><actualCarTax>68.15</actualCarTax><pickUpDate>03/16/2019 07:30:00</pickUpDate><dropOffDate>03/17/2019 12:20:00</dropOffDate><recordLocator>AFWAIL</recordLocator><confirmationNumber>H7863447030</confirmationNumber><CurrencyCodeKey>USD</CurrencyCodeKey><PolicyReasonCodeId>0</PolicyReasonCodeId><CarPolicyKey>0</CarPolicyKey><contractCode></contractCode><TripPassengerInfoKey>0</TripPassengerInfoKey><rateTypeCode>RCUE1</rateTypeCode><OperationTimeStart></OperationTimeStart><OperationTimeEnd></OperationTimeEnd><PickupLocationInfo></PickupLocationInfo><carRules></carRules><RPH>2</RPH><InvoiceNumber></InvoiceNumber><MileageAllowance>UNL</MileageAllowance><PhoneNumber></PhoneNumber><PickupAddress></PickupAddress><DropAddress></DropAddress><RequestType></RequestType></TripCarResponse></Car></TripComponents><UpdateTrip><IsAirInsert>false</IsAirInsert><IsHotelInsert>false</IsHotelInsert><IsCarInsert>false</IsCarInsert><IsRailInsert>false</IsRailInsert><IsAirCancel>false</IsAirCancel><IsHotelCancel>false</IsHotelCancel><IsCarCancel>false</IsCarCancel><IsRailCancel>false</IsRailCancel><Trip><userKey>0</userKey><recordLocator>AFWAIL</recordLocator><tripStatusKey>2</tripStatusKey><agencyKey>1</agencyKey><siteKey>1</siteKey><tripComponentType>7</tripComponentType><tripRequestKey>0</tripRequestKey><meetingCodeKey></meetingCodeKey><tripAdultsCount>1</tripAdultsCount><tripSeniorsCount>0</tripSeniorsCount><tripChildCount>0</tripChildCount><tripInfantCount>0</tripInfantCount><tripYouthCount>0</tripYouthCount><tripInfantWithSeatCount>0</tripInfantWithSeatCount><noOfTotalTraveler>0</noOfTotalTraveler><noOfRooms>1</noOfRooms><noOfCars>1</noOfCars><isAudit>False</isAudit><tripCreationPath>2</tripCreationPath><TrackingLogID>0</TrackingLogID><bookingFeeARC></bookingFeeARC><Issue_Date>09/11/2018 00:00:00</Issue_Date><SabreCreationDate>09/11/2018 02:29:00</SabreCreationDate><groupKey>0</groupKey><EventKey></EventKey><AttendeeGuid></AttendeeGuid><UserIPAddress></UserIPAddress><SessionId>930e9aa8-f596-40bb-8abd-48fb5253a3f5</SessionId><subsiteKey></subsiteKey><isArrangerBookForGuest>False</isArrangerBookForGuest><FailureReason></FailureReason><Culture></Culture><AncillaryServices></AncillaryServices><AncillaryFees>0</AncillaryFees><isGroupBooking>False</isGroupBooking><isUserCreatedSavedTrip>true</isUserCreatedSavedTrip><IsRequestApproval>False</IsRequestApproval><IsRequestNotification>False</IsRequestNotification><AdvantageNumber></AdvantageNumber><CartNumber></CartNumber></Trip><UpdateTrip><tripTotalBaseCost>559.67</tripTotalBaseCost><tripTotalTaxCost>123.27</tripTotalTaxCost><startdate>03/16/2019 00:00:00</startdate><enddate>03/17/2019 12:35:00</enddate><bookingCharges>0</bookingCharges><isOnlineBooking>True</isOnlineBooking></UpdateTrip></UpdateTrip><TripTicketInfos><TripTicketInfo><tripKey>0</tripKey><recordLocator>AFWAIL</recordLocator><isExchanged>False</isExchanged><isRefunded>False</isRefunded><isVoided>False</isVoided><oldTicketNumber>0167176193413</oldTicketNumber><newTicketNumber></newTicketNumber><issuedDate>09/11/2018 03:33:00</issuedDate><currency>USD</currency><oldFare>0</oldFare><newFare>0</newFare><addCollectFare>0</addCollectFare><serviceCharge>0</serviceCharge><residualFare>0</residualFare><TotalFare>411.4</TotalFare><ExchangeFee>0</ExchangeFee><BaseFare>356.28</BaseFare><TaxFare>55.12</TaxFare></TripTicketInfo></TripTicketInfos></UpdatePurchasedTrip>'
-- EXEC [dbo].[UpdatePurchaseTrip_Purchase] @xmldata
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePurchaseTrip_Purchase] 
	@xml XML
AS
BEGIN
	 SET NOCOUNT ON
	DECLARE @XmlDocumentHandle int, @TripPassenger SavePurchaseTrip_TripPassenger 
	EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @Xml
	
	DECLARE @TripKey INT
	DECLARE @TripStatusKey INT
	DECLARE @RecordLocator VARCHAR(50)
	DECLARE @IsAirInsert bit, @IsHotelInsert bit, @IsCarInsert bit, @IsRailInsert bit
	DECLARE @IsAirCancel bit, @IsHotelCancel bit, @IsCarCancel bit, @IsRailCancel bit

	SELECT	 @IsAirInsert=IsAirInsert
			,@IsHotelInsert=IsHotelInsert
			,@IsCarInsert=IsCarInsert
			,@IsRailInsert=IsRailInsert
			,@IsAirCancel=IsAirCancel
			,@IsHotelCancel=IsHotelCancel
			,@IsCarCancel=IsCarCancel
			,@IsRailCancel=IsRailCancel
	FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/UpdateTrip')  
	WITH (	 
			 IsAirInsert	BIT	'(./IsAirInsert/text())[1]'
			,IsHotelInsert	BIT	'(./IsHotelInsert/text())[1]'
			,IsCarInsert	BIT	'(./IsCarInsert/text())[1]'
			,IsRailInsert	BIT	'(./IsRailInsert/text())[1]'
			,IsAirCancel	BIT	'(./IsAirCancel/text())[1]'
			,IsHotelCancel	BIT	'(./IsHotelCancel/text())[1]'
			,IsCarCancel	BIT	'(./IsCarCancel/text())[1]'
			,IsRailCancel	BIT	'(./IsRailCancel/text())[1]'
		 )
	
	SELECT	 @TripStatusKey=tripStatusKey
			,@RecordLocator=RecordLocator
	FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/UpdateTrip/Trip')  
	WITH (	 
			 tripStatusKey	INT	'(./tripStatusKey/text())[1]'
			,RecordLocator	Varchar(10)	'(./recordLocator/text())[1]'
		 )
	
		
	IF @TripStatusKey IN(2, 12, 23, 24, 26)--check for Purchase, PurchasedAward, PendingAward, Exchanged
	BEGIN

		CREATE TABLE #TripKey (EventId int)
		INSERT INTO #TripKey EXEC USP_DeleteTripDetailsForMultiPax   @recordLocator,@TripStatusKey
		SET @TripKey = (SELECT * FROM #TripKey)
		
		DROP TABLE #TripKey 

		--EXEC @TripKey=USP_DeleteTripDetailsForMultiPax  @recordLocator,@TripStatusKey
		
		IF (@TripKey > 0) -- Check for TripKey > 0
		BEGIN
			print @TripKey
			INSERT INTO @TripPassenger
			select TripHistoryKey as TripHistoryKey,PassengerKey as PassengerKey,TripPassengerInfoKey as TripPassengerInfoKey  from TripPassengerInfo where TripKey=@TripKey

			-- Air --
			IF @XML.exist('(/UpdatePurchasedTrip/TripComponents/Air)')=1
			BEGIN
					PRINT 'Air Update'
					DECLARE @xmlTripAir XML
					SELECT @xmlTripAir = @xml.query('/UpdatePurchasedTrip/TripComponents/Air')

					EXEC [dbo].[UpdatePurchaseTrip_Air] @xmlTripAir, @IsAirInsert, @IsAirCancel, @TripKey, @TripPassenger

					IF(@IsAirCancel = 0)
					BEGIN
						UPDATE [TripPassengerAirVendorPreference]  SET Active = 0   WHERE [TripKey] = @TripKey
							
						INSERT INTO TripPassengerAirVendorPreference 
						( 		 TripKey
								,PassengerKey 
								,ID 
								,AirLineCode
								,AirLineName 
								,PreferenceNo 
								,ProgramNumber
								,TripPassengerInfoKey 
						)	 
						SELECT	 @TripKey 
								,A.PassengerKey 
								,A.ID 
								,A.AirLineCode
								,A.AirLineName 
								,A.PreferenceNo 
								,A.ProgramNumber
								,O.TripPassengerInfoKey 
						FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerAirPreference/TripPassengerAirVendorPreferences/TripPassengerAirVendorPreference')  
						WITH (	 PassengerKey			INT				'(./PassengerKey/text())[1]'
								,ID						INT				'(./ID/text())[1]'
								,AirLineCode			NVARCHAR(60)	'(./AirLineCode/text())[1]'
								,AirLineName			NVARCHAR(100)	'(./AirLineName/text())[1]'
								,PreferenceNo			NVARCHAR(100)	'(./PreferenceNo/text())[1]'
								,ProgramNumber			NVARCHAR(100)	'(./ProgramNumber/text())[1]'
							) A
						INNER JOIN @TripPassenger O on O.PassengerKey = A.PassengerKey
					END
			END
			ELSE IF (@IsAirCancel = 1 )
			BEGIN
				PRINT 'Air Cancel'
				Declare @airResponseKey uniqueidentifier 		
				select @airResponseKey = airresponsekey from trip..TripAirResponse where tripGUIDKey in( select tripPurchasedKey from trip..Trip where tripkey = @TripKey )
				Update [TripAirResponse]  set isDeleted = 1 where airResponseKey = @airResponseKey
			END
			
			-- Car --
			IF @XML.exist('(/UpdatePurchasedTrip/TripComponents/Car)')=1
			BEGIN
					PRINT 'Car Update'

					DECLARE @xmlTripCar XML
					SELECT @xmlTripCar = @xml.query('/UpdatePurchasedTrip/TripComponents/Car')

					EXEC [dbo].[UpdatePurchaseTrip_Car] @xmlTripCar, @IsCarInsert, @IsCarCancel, @TripKey, @TripPassenger

					IF(@IsCarCancel = 0)
					BEGIN
						UPDATE	[TripPassengerCarVendorPreference]  
						SET		Active = 0   
						WHERE	[TripKey] = @TripKey
	
	
						INSERT INTO TripPassengerCarVendorPreference
						(
								 TripKey
								,PassengerKey
								,Id
								,CarVendorCode
								,CarVendorName 
								,PreferenceNo
								,ProgramNumber
								,TripPassengerInfoKey
						)
						SELECT	 @TripKey
								,A.PassengerKey
								,A.Id
								,A.CarVendorCode
								,A.CarVendorName 
								,A.PreferenceNo
								,A.ProgramNumber
								,O.TripPassengerInfoKey 
						FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerCarPreference/TripPassengerCarVendorPreferences/TripPassengerCarVendorPreference')  
						WITH (
								 PassengerKey			INT				'(./PassengerKey/text())[1]'
								,Id						INT				'(./ID/text())[1]'
								,CarVendorCode			NVARCHAR(60)	'(./CarVendorCode/text())[1]'
								,CarVendorName			NVARCHAR(1000)	'(./CarVendorName/text())[1]'
								,PreferenceNo			NVARCHAR(100)	'(./PreferenceNo/text())[1]'
								,ProgramNumber			NVARCHAR(100)	'(./ProgramNumber/text())[1]'
								,TripPassengerInfoKey	INT				'(./TripPassengerInfoKey/text())[1]'
								)  A
						INNER JOIN @TripPassenger O on O.PassengerKey = A.PassengerKey
		 						 
					END
			END
			ELSE IF (@IsCarCancel = 1 )
			BEGIN				
				PRINT 'Car Cancel'						
				Declare @CarResponseKey uniqueidentifier 		
				select @CarResponseKey = carResponseKey from trip..TripCarResponse where tripGUIDKey in( select tripPurchasedKey from trip..Trip where tripkey = @TripKey )
				Update	TripCarResponse  set isDeleted = 1 WHERE	carResponseKey = @CarResponseKey
			END

			-- Hotel --
			IF @XML.exist('(/UpdatePurchasedTrip/TripComponents/Hotel)')=1
			BEGIN
					PRINT 'Hotel Update'
					DECLARE @xmlTripHotel XML
					SELECT @xmlTripHotel = @xml.query('/UpdatePurchasedTrip/TripComponents/Hotel')

					EXEC [dbo].[UpdatePurchaseTrip_Hotel] @xmlTripHotel, @IsHotelInsert, @IsHotelCancel, @TripKey, @TripPassenger 

					IF(@IsHotelCancel = 0)
					BEGIN

						UPDATE  HV  
						SET HV.Active = 0   
						FROM [TripPassengerHotelVendorPreference] HV
						INNER JOIN @TripPassenger O on O.TripPassengerInfoKey = HV.TripPassengerInfoKey
						WHERE HV.TripKey = @TripKey --AND HV.TripPassengerInfoKey = @TripPassengerInfoKey 
	
						INSERT INTO TripPassengerHotelVendorPreference
						( 
								 TripKey
								,PassengerKey
								,ID
								,HotelChainCode
								,HotelChainName
								,PreferenceNo
								,ProgramNumber
								,TripPassengerInfoKey
						)  
						SELECT	 @TripKey
								,A.PassengerKey
								,A.ID
								,A.HotelChainCode
								,A.HotelChainName
								,A.PreferenceNo
								,A.ProgramNumber
								,O.TripPassengerInfoKey 
						FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerHotelPreference/TripPassengerHotelVendorPreferences/TripPassengerHotelVendorPreference')  
						WITH (
								 PassengerKey			INT				'(./PassengerKey/text())[1]'
								,ID						INT				'(./ID/text())[1]'
								,HotelChainCode			NVARCHAR(60)	'(./HotelChainCode/text())[1]'
								,HotelChainName			NVARCHAR(1000)	'(./HotelChainName/text())[1]'
								,PreferenceNo			NVARCHAR(100)	'(./PreferenceNo/text())[1]'
								,ProgramNumber			NVARCHAR(100)	'(./ProgramNumber/text())[1]'
							  ) A
						INNER JOIN @TripPassenger O on O.PassengerKey = A.PassengerKey
					END
			END
			ELSE IF (@IsHotelCancel = 1 )
			BEGIN				
				PRINT 'Hotel Cancel'	
				Declare @HotelResponseKey uniqueidentifier 		
				select @HotelResponseKey = hotelResponseKey from trip..TripHotelResponse where tripGUIDKey in( select tripPurchasedKey from trip..Trip where tripkey = @TripKey )					
				Update	TripHotelResponse  set isDeleted = 1 WHERE	hotelResponseKey = @HotelResponseKey
			END			
						
			/*
			-- Insurance --
			IF @XML.exist('(/UpdatePurchasedTrip/TripComponents/Car)')=1
			BEGIN
					PRINT 'Insurance Update'
					--EXEC [dbo].[UpdatePurchaseTrip_Insurance] @xml
			END
			ELSE
			BEGIN
				
				DECLARE @CarResponseKey UNIQUEIDENTIFIER
				
				SELECT	@CarResponseKey=carResponseKey 
				FROM	TripinsuranceResponse 
				WHERE	tripKey = @tripKey
					
					
				Update	TripCarResponse  set isDeleted = 1 
				WHERE	carResponseKey = @HotelResponseKey
			END
			*/
			
			-- Activity --
			IF @XML.exist('(/UpdatePurchasedTrip/TripComponents/Activity)')=1
			BEGIN
					PRINT 'Activity Update'
					--EXEC [dbo].[UpdatePurchaseTrip_Activity] @xml
			END
			ELSE
			BEGIN
				
				DECLARE @ActivityResponseKey UNIQUEIDENTIFIER
				
				SELECT	@ActivityResponseKey=ActivityResponseKey 
				FROM	TripActivityResponse 
				WHERE	tripKey = @tripKey
					
				Update	TripActivityResponse  set isDeleted = 1 
				WHERE	ActivityResponseKey = @ActivityResponseKey
			END
			
			-- Rail --
			IF @XML.exist('(/UpdatePurchasedTrip/TripComponents/Rail)')=1
			BEGIN
					PRINT 'Rail Update'
					EXEC [dbo].[UpdatePurchaseTrip_Rail] @xml, @IsRailInsert, @IsRailCancel--, @TripKey, @TripPassenger
			END
			ELSE
			BEGIN
				
				DECLARE @RailResponseKey UNIQUEIDENTIFIER
				
				SELECT	@RailResponseKey=RailResponseKey 
				FROM	TripRailResponse 
				WHERE	tripKey = @tripKey
					
				Update	TripRailResponse  set isDeleted = 1 
				WHERE	RailResponseKey = @RailResponseKey
			END
			
			-- Reporting Field --
			IF @XML.exist('(/UpdatePurchasedTrip/TripComponents/Report)')=1
			BEGIN
					PRINT 'Reporting Field Update'
					--EXEC [dbo].[USP_UpdatePurchaseTrip_Report] @xml
			END
			ELSE
			BEGIN
				
				DECLARE @CompanyUDIDNumber INT
				
				SELECT	@CompanyUDIDNumber=CompanyUDIDNumber 
				FROM	TripPassengerUDIDInfo 
				WHERE	tripKey = @tripKey
				
					
				Update	TripPassengerUDIDInfo  set Active = 0 
				WHERE	tripKey = @tripKey
				AND		CompanyUDIDNumber = @CompanyUDIDNumber
				
			END

			------------------------------------- Start Remarks -------------------------------------------------------------------------
			IF @XML.exist('(/UpdatePurchasedTrip/Remarks/Remark)')=1
			BEGIN
				INSERT INTO TripPNRRemarks
				(
						  TripKey
						 ,RemarkFieldName
						 ,RemarkFieldValue
						 ,TripTypeKey
						 ,RemarksDesc
						 ,GeneratedType
						 ,CreatedOn
						 ,Active
				)
				SELECT	  @TripKey
						 ,RemarkFieldName
						 ,RemarkFieldValue
						 ,TripTypeKey
						 ,RemarksDesc
						 ,GeneratedType
						 ,CreatedOn
						 ,Active
				FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/Remarks/Remark')  
				WITH (	  
						  RemarkFieldName	NVARCHAR(160)	'(./RemarkFieldName/text())[1]'
						 ,RemarkFieldValue	NVARCHAR(max)	'(./RemarkFieldValue/text())[1]'
						 ,TripTypeKey		INT				'(./TripTypeKey/text())[1]'
						 ,RemarksDesc		NVARCHAR(MAX)	'(./RemarksDesc/text())[1]'
						 ,GeneratedType		INT				'(./GeneratedType/text())[1]'
						 ,CreatedOn			DATETIME		'(./CreatedOn/text())[1]'
						 ,Active			BIT				'(./Active/text())[1]'
					  )
			END
			------------------------------------- End Remarks -------------------------------------------------------------------------

			------------------------------------- Start Credit Card -------------------------------------------------------------------------
			IF @XML.exist('(/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerCreditCardInfos/TripPassengerCreditCardInfo)')=1
			BEGIN
				DECLARE @creditCardLastFourDigit INT

				SELECT	  
						@creditCardLastFourDigit=creditCardLastFourDigit
				FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerCreditCardInfos/TripPassengerCreditCardInfo')  
				WITH (	
						creditCardLastFourDigit			int	'(./creditCardLastFourDigit/text())[1]'
					 )

				IF EXISTS(SELECT [TripPassengerCreditCardInfoKey]  FROM [TripPassengerCreditCardInfo] WHERE creditCardLastFourDigit=@creditCardLastFourDigit and tripKey = @tripKey AND Active = 1)
				BEGIN

					UPDATE [TripPassengerCreditCardInfo] SET Active = 0 where tripKey = @tripKey

					INSERT INTO TripPassengerCreditCardInfo
					( 
						 TripKey 
						,PassengerKey 
						,TripTypeComponent 
						,CreditCardKey
						,creditCardVendorCode
						,creditCardDescription
						,creditCardLastFourDigit
						,expiryMonth
						,expiryYear
						,NameOnCard
					)  
					SELECT	 
						 @TripKey 
						,PassengerKey 
						,TripTypeComponent 
						,CreditCardKey
						,creditCardVendorCode
						,creditCardDescription
						,creditCardLastFourDigit
						,expiryMonth
						,expiryYear
						,NameOnCard
				FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerCreditCardInfos/TripPassengerCreditCardInfo')  
				WITH (	
						 PassengerKey			int	'(./PassengerKey/text())[1]'
						,TripTypeComponent			int	'(./TripTypeComponent/text())[1]'
						,CreditCardKey			int	'(./CreditCardKey/text())[1]'
						,creditCardVendorCode			nchar(4)	'(./creditCardVendorCode/text())[1]'
						,creditCardDescription			varchar(50)	'(./creditCardDescription/text())[1]'
						,creditCardLastFourDigit			int	'(./creditCardLastFourDigit/text())[1]'
						,expiryMonth			int	'(./expiryMonth/text())[1]'
						,expiryYear			int	'(./expiryYear/text())[1]'
						,NameOnCard			nvarchar(1000)	'(./NameOnCard/text())[1]'
					 )

				END     
			END                       
			------------------------------------- End Credit Card ------------------------------------------------------------------------
			IF @XML.exist('(/UpdatePurchasedTrip/UpdateTrip/Trip)')=1
			BEGIN
				UPDATE TRIP
				SET		  tripAdultsCount=ISNULL(tripAdultsCount_XML,tripAdultsCount)			
						 ,tripSeniorsCount=	ISNULL(tripSeniorsCount_XML	,tripSeniorsCount)		
						 ,tripChildCount=	ISNULL(tripChildCount_XML,tripChildCount)				
						 ,tripInfantCount=	ISNULL(tripInfantCount_XML,tripInfantCount)			
						 ,tripYouthCount=	ISNULL(tripYouthCount_XML,tripYouthCount)				
						 ,PurchaseComponentType=ISNULL(PurchaseComponentType_XML,PurchaseComponentType)		
						 ,noOfRooms=ISNULL(noOfRooms_XML,noOfRooms)					
						 ,noOfCars=ISNULL(noOfCars_XML,noOfCars)				
						 ,tripInfantWithSeatCount=ISNULL(tripInfantWithSeatCount_XML,tripInfantWithSeatCount)
						 ,IssueDate=ISNULL(IssueDate_XML,IssueDate)					
						 ,bookingFeeARC=ISNULL(bookingFeeARC_XML,bookingFeeARC)				
						 ,meetingCodeKey=ISNULL(meetingCodeKey_XML,meetingCodeKey)				
						 ,subsiteKey=ISNULL(subsiteKey_XML,subsiteKey)					
						 ,AncillaryServices=ISNULL(AncillaryServices_XML,AncillaryServices)			
						 ,AncillaryFees=ISNULL(AncillaryFees_XML,AncillaryFees)				
						 ,ModifiedDateTime=GETDATE()
						 ,DKNumber = ISNULL(DKNumber_XML, DKNumber)
						 ,isUpgradeBooking=ISNULL(isUpgradeBooking_XML, isUpgradeBooking)
				FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/UpdateTrip/Trip')  
				WITH (	
						 tripAdultsCount_XML			int			'(./tripAdultsCount/text())[1]'
						,tripSeniorsCount_XML			int			'(./tripSeniorsCount/text())[1]'
						,tripChildCount_XML				int			'(./tripChildCount/text())[1]'
						,tripInfantCount_XML			INT			'(./tripInfantCount/text())[1]'
						,tripYouthCount_XML				INT			'(./tripYouthCount/text())[1]'
						,PurchaseComponentType_XML		int			'(./tripComponentType/text())[1]'
						,noOfRooms_XML					int			'(./noOfRooms/text())[1]'
						,noOfCars_XML					int			'(./noOfCars/text())[1]'
						,tripInfantWithSeatCount_XML	INT			'(./tripInfantWithSeatCount/text())[1]'
						,IssueDate_XML					DATETIME	'(./Issue_Date/text())[1]'
						,bookingFeeARC_XML				varchar(20)	'(./bookingFeeARC/text())[1]'
						,meetingCodeKey_XML				varchar(50)	'(./meetingCodeKey/text())[1]'
						,subsiteKey_XML					INT			'(./subsiteKey/text())[1]'
						,AncillaryServices_XML			varchar(50)	'(./AncillaryServices/text())[1]'
						,AncillaryFees_XML				FLOAT		'(./AncillaryFees/text())[1]'
						,DKNumber_XML					varchar(20)	'(./DKNumber/text())[1]'
						,isUpgradeBooking_XML			TINYINT	'(./isUpgradeBooking/text())[1]'
					 )
				WHERE TripKey = @TripKey
			END

			IF @XML.exist('(/UpdatePurchasedTrip/UpdateTrip/UpdateTrip)')=1
			BEGIN
				UPDATE TRIP
				SET		  startDate=ISNULL(startDate_XML,startDate)			
						 ,endDate=	ISNULL(endDate_XML	,endDate)		
						 ,tripTotalBaseCost=	ISNULL(tripTotalBaseCost_XML,tripTotalBaseCost)				
						 ,tripTotalTaxCost=	ISNULL(tripTotalTaxCost_XML,tripTotalTaxCost)			
						 ,bookingCharges=	ISNULL(bookingCharges_XML,bookingCharges)				
				FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/UpdateTrip/UpdateTrip')  
				WITH (	
						 startDate_XML			DATETIME		'(./startdate/text())[1]'
						,endDate_XML			DATETIME		'(./enddate/text())[1]'
						,tripTotalBaseCost_XML	FLOAT			'(./tripTotalBaseCost/text())[1]'
						,tripTotalTaxCost_XML	FLOAT			'(./tripTotalTaxCost/text())[1]'
						,bookingCharges_XML		FLOAT			'(./bookingCharges/text())[1]'
					
					 )
				WHERE TripKey = @TripKey
			END
		END	
		ELSE
		BEGIN
				RAISERROR (	'No Records Found For PNR in DB', -- Message text.
							16, -- Severity.
							1 -- State.
						  );
		END
		
	END
	ELSE IF @TripStatusKey IN(5, 13, 28) --Check for Canceled, CanceledAward, Banked
	BEGIN
		EXEC USP_DeleteTripDetailsForMultiPax @recordLocator,@TripStatusKey
	END

	IF @XML.exist('(/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerCoworker/Coworker)')=1
	BEGIN
	DECLARE @FirstName NVARCHAR(400), @LastName NVARCHAR(400),@EmailAddress VARCHAR(100),@TripPassengerInfoKey INT
		SELECT @FirstName=FirstName
			,@LastName=LastName
			,@EmailAddress=EmailAddress
	FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerCoworker/Coworker')  
	WITH (	 
			 FirstName	NVARCHAR(400)	'(./FirstName/text())[1]'
			,LastName	NVARCHAR(400)	'(./LastName/text())[1]'
			,EmailAddress	VARCHAR(100)	'(./EmailAddress/text())[1]'
		 )
	   SELECT @TripPassengerInfoKey = TripPassengerInfoKey from TripPassengerInfo where TripKey=@TripKey AND IsPrimaryPassenger = 1
		UPDATE Trip..TripCoWorker
		SET	FirstName = @FirstName,
			LastName = @LastName,
			Email = @EmailAddress
		WHERE TripPassengerInfoKey = @TripPassengerInfoKey
	END
	
	IF @XML.exist('(/UpdatePurchasedTrip/TripTicketInfos/TripTicketInfo)')=1
	BEGIN
			update TripTicketInfo set tripKey = 0 where tripKey = @TripKey
			---- TripTicketInfo
			INSERT INTO TripTicketInfo 
					(tripKey
					, recordLocator
					, isExchanged
					, isVoided
					, isRefunded
					, oldTicketNumber
					, newTicketNumber
					, createdDate
					, issuedDate
					, currency
					, oldFare
					, newFare
					, addCollectFare
					, serviceCharge
					, residualFare
					, TotalFare
					, ExchangeFee
					, BaseFare
					, TaxFare
					, IsHostStatusTicketed
					)	 
			 SELECT	 
					 @TripKey	 
					, recordLocator
					, isExchanged
					, isVoided
					, isRefunded
					, oldTicketNumber
					, newTicketNumber
					, GETDATE() AS createdDate
					,CASE WHEN (charindex('-', issuedDate) > 0) THEN CONVERT(DATETIME, issuedDate, 103) ELSE issuedDate END AS issuedDate
					, currency
					, oldFare
					, newFare
					, addCollectFare
					, serviceCharge
					, residualFare
					, TotalFare
					, ExchangeFee
					, BaseFare
					, TaxFare
					, IsHostStatusTicketed
			FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripTicketInfos/TripTicketInfo')  
			WITH (	 recordLocator			varchar(10)		'(./recordLocator/text())[1]'
					, isExchanged			BIT				'(./isExchanged/text())[1]'
					, isVoided				BIT				'(./isVoided/text())[1]'
					, isRefunded			BIT				'(./isRefunded/text())[1]'
					, oldTicketNumber		varchar(20)		'(./oldTicketNumber/text())[1]'
					, newTicketNumber		varchar(20)		'(./newTicketNumber/text())[1]'
					, issuedDate			DATETIME		'(./issuedDate/text())[1]'
					, currency				varchar(10)		'(./currency/text())[1]'
					, oldFare				FLOAT			'(./oldFare/text())[1]'
					, newFare				FLOAT			'(./newFare/text())[1]'
					, addCollectFare		FLOAT			'(./addCollectFare/text())[1]'
					, serviceCharge			FLOAT			'(./serviceCharge/text())[1]'
					, residualFare			FLOAT			'(./residualFare/text())[1]'
					, TotalFare				FLOAT			'(./TotalFare/text())[1]'
					, ExchangeFee			FLOAT			'(./ExchangeFee/text())[1]'
					, BaseFare				FLOAT			'(./BaseFare/text())[1]'
					, TaxFare				FLOAT			'(./TaxFare/text())[1]'
					, IsHostStatusTicketed	BIT				'(./isHostStatusTicketed/text())[1]'

				)
	END
	select @TripKey
	EXEC sp_xml_removedocument @XmlDocumentHandle
	SET NOCOUNT OFF
END
GO
