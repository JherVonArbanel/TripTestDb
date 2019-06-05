SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <5th Sep 17>
-- Description:	<To Insert into Trip History Table>
-- declare @xmldata xml = N'<SavePurchasedTrip><TripPassenger><TripPassengerInfos><TripPassengerInfo><TripHistoryKey>00000000-0000-0000-0000-000000000000</TripHistoryKey><PassengerKey>562934</PassengerKey><PassengerTypeKey>1</PassengerTypeKey><IsPrimaryPassenger>True</IsPrimaryPassenger><AdditionalRequest></AdditionalRequest><PassengerEmailID>steve@via.biz</PassengerEmailID><PassengerFirstName>SteveRo</PassengerFirstName><PassengerLastName>Edgerton</PassengerLastName><PassengerLocale></PassengerLocale><PassengerTitle></PassengerTitle><PassengerGender>M</PassengerGender><PassengerBirthDate>5/8/1982 12:00:00 AM</PassengerBirthDate><TravelReferenceNo>1.1</TravelReferenceNo><TripRequestKey>521370</TripRequestKey><IsExcludePricingInfo>false</IsExcludePricingInfo><TripPassengerCreditCardInfos><TripPassengerCreditCardInfo><TripTypeComponent>7</TripTypeComponent><CreditCardKey>1717</CreditCardKey><creditCardVendorCode>VI</creditCardVendorCode><creditCardDescription>AirNew</creditCardDescription><creditCardLastFourDigit>1111</creditCardLastFourDigit><expiryMonth>1</expiryMonth><expiryYear>2021</expiryYear><NameOnCard>Milind Lad</NameOnCard><UsedforAir>1</UsedforAir><UsedforHotel>0</UsedforHotel><UsedforCar>0</UsedforCar><creditCardTypeKey>0</creditCardTypeKey></TripPassengerCreditCardInfo><TripPassengerCreditCardInfo><TripTypeComponent>7</TripTypeComponent><CreditCardKey>1717</CreditCardKey><creditCardVendorCode>VI</creditCardVendorCode><creditCardDescription>AirNew</creditCardDescription><creditCardLastFourDigit>1111</creditCardLastFourDigit><expiryMonth>1</expiryMonth><expiryYear>2021</expiryYear><NameOnCard>Milind Lad</NameOnCard><UsedforAir>0</UsedforAir><UsedforHotel>1</UsedforHotel><UsedforCar>0</UsedforCar><creditCardTypeKey>0</creditCardTypeKey></TripPassengerCreditCardInfo></TripPassengerCreditCardInfos><TripPassengerPreferences><TripPassengerAirPreference><ID>0</ID><OriginAirportCode></OriginAirportCode><TicketDelivery></TicketDelivery><AirSeatingType>2</AirSeatingType><AirRowType>0</AirRowType><AirMealType>3</AirMealType><AirSpecialSevicesType>0</AirSpecialSevicesType></TripPassengerAirPreference><TripPassengerHotelPreference><TripPassengerHotelVendorPreferences><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>AN</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>1</PreferenceNo><ProgramNumber>ANA123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>HS</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>2</PreferenceNo><ProgramNumber>ABA123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>HI</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>3</PreferenceNo><ProgramNumber>HOL123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>HP</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>4</PreferenceNo><ProgramNumber>HYP123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>HX</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>5</PreferenceNo><ProgramNumber>HAMP123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>NY</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>6</PreferenceNo><ProgramNumber>AFF123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>OT</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>7</PreferenceNo><ProgramNumber>OTH123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>GI</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>8</PreferenceNo><ProgramNumber>DDD123</ProgramNumber></TripPassengerHotelVendorPreference><TripPassengerHotelVendorPreference><ID>0</ID><HotelChainCode>HH</HotelChainCode><HotelChainName></HotelChainName><PreferenceNo>9</PreferenceNo><ProgramNumber>HOTEL789</ProgramNumber></TripPassengerHotelVendorPreference></TripPassengerHotelVendorPreferences></TripPassengerHotelPreference><TripPassengerCarPreference><TripPassengerCarVendorPreferences><TripPassengerCarVendorPreference><ID>0</ID><CarVendorCode>ZD</CarVendorCode><CarVendorName></CarVendorName><PreferenceNo>1</PreferenceNo><ProgramNumber>SP874C</ProgramNumber></TripPassengerCarVendorPreference><TripPassengerCarVendorPreference><ID>0</ID><CarVendorCode>ZE</CarVendorCode><CarVendorName></CarVendorName><PreferenceNo>2</PreferenceNo><ProgramNumber>HER123</ProgramNumber></TripPassengerCarVendorPreference><TripPassengerCarVendorPreference><PassengerKey>562934</PassengerKey><ID>0</ID><CarVendorCode>ZR</CarVendorCode><CarVendorName></CarVendorName><PreferenceNo>3</PreferenceNo><ProgramNumber>DOL123</ProgramNumber></TripPassengerCarVendorPreference></TripPassengerCarVendorPreferences></TripPassengerCarPreference></TripPassengerPreferences><TripPassengerUDIDInfos><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3589</CompanyUDIDKey><CompanyUDIDDescription>ravi</CompanyUDIDDescription><CompanyUDIDNumber>3</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>17</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>0</ReportFieldType><TextEntryType>1</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>S Edgerton</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3587</CompanyUDIDKey><CompanyUDIDDescription>Test1</CompanyUDIDDescription><CompanyUDIDNumber>14</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>milind12345</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>11</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>0</ReportFieldType><TextEntryType>1</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>218.98</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3594</CompanyUDIDKey><CompanyUDIDDescription>q</CompanyUDIDDescription><CompanyUDIDNumber>12</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>218.98</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>300</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>steve@via.biz</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3054</CompanyUDIDKey><CompanyUDIDDescription>TestData</CompanyUDIDDescription><CompanyUDIDNumber>5</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>True</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3055</CompanyUDIDKey><CompanyUDIDDescription>DropData</CompanyUDIDDescription><CompanyUDIDNumber>8</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3376</CompanyUDIDKey><CompanyUDIDDescription>PullDown</CompanyUDIDDescription><CompanyUDIDNumber>1</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>True</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3402</CompanyUDIDKey><CompanyUDIDDescription>BookingANWS</CompanyUDIDDescription><CompanyUDIDNumber>81</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>5</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3403</CompanyUDIDKey><CompanyUDIDDescription>BookingANWSC</CompanyUDIDDescription><CompanyUDIDNumber>80</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>6</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3590</CompanyUDIDKey><CompanyUDIDDescription>MyField</CompanyUDIDDescription><CompanyUDIDNumber>13</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>True</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>2</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3591</CompanyUDIDKey><CompanyUDIDDescription>testfield</CompanyUDIDDescription><CompanyUDIDNumber>16</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>2</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3593</CompanyUDIDKey><CompanyUDIDDescription>abcc</CompanyUDIDDescription><CompanyUDIDNumber>28</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>2</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3595</CompanyUDIDKey><CompanyUDIDDescription>ewr</CompanyUDIDDescription><CompanyUDIDNumber>9</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3597</CompanyUDIDKey><CompanyUDIDDescription>Numeric</CompanyUDIDDescription><CompanyUDIDNumber>23</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue></PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3380</CompanyUDIDKey><CompanyUDIDDescription>Email</CompanyUDIDDescription><CompanyUDIDNumber>6</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>4</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>DEVELOPMENT</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>3055</CompanyUDIDKey><CompanyUDIDDescription>DropData</CompanyUDIDDescription><CompanyUDIDNumber>8</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>1</ReportFieldType><TextEntryType>0</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>5</PassengerUDIDValue></TripPassengerUDIDInfo><TripPassengerUDIDInfo><PassengerKey>562934</PassengerKey><CompanyUDIDKey>0</CompanyUDIDKey><CompanyUDIDDescription></CompanyUDIDDescription><CompanyUDIDNumber>18</CompanyUDIDNumber><CompanyUDIDOptionID>0</CompanyUDIDOptionID><CompanyUDIDOptionCode></CompanyUDIDOptionCode><CompanyUDIDOptionText></CompanyUDIDOptionText><IsPrintInvoice>False</IsPrintInvoice><ReportFieldType>2</ReportFieldType><TextEntryType>1</TextEntryType><UserID>562934</UserID><PassengerUDIDValue>Cap90</PassengerUDIDValue></TripPassengerUDIDInfo></TripPassengerUDIDInfos></TripPassengerInfo></TripPassengerInfos></TripPassenger><TripComponents><Air><TripAirPrices><TripAirPrice><tripCategory>Actual</tripCategory><tripAdultBase>190.49</tripAdultBase><tripAdultTax>28.49</tripAdultTax><tripSeniorBase>0</tripSeniorBase><tripSeniorTax>0</tripSeniorTax><tripYouthBase>0</tripYouthBase><tripYouthTax>0</tripYouthTax><tripChildBase>0</tripChildBase><tripChildTax>0</tripChildTax><tripInfantBase>0</tripInfantBase><tripInfantTax>0</tripInfantTax><tripInfantWithSeatBase>0</tripInfantWithSeatBase><tripInfantWithSeatTax>0</tripInfantWithSeatTax><tripAirResponseTaxes><tripAirResponseTax><amount>4.1</amount><designator></designator><nature></nature><description>Segment Fee</description></tripAirResponseTax><tripAirResponseTax><amount>5.6</amount><designator></designator><nature></nature><description>Passenger Facility Charge</description></tripAirResponseTax><tripAirResponseTax><amount>4.5</amount><designator></designator><nature></nature><description>September 11th Security Fee</description></tripAirResponseTax><tripAirResponseTax><amount>14.29</amount><designator></designator><nature></nature><description>Excise Tax</description></tripAirResponseTax></tripAirResponseTaxes></TripAirPrice><TripAirPrice><tripCategory>Reprice</tripCategory><tripAdultBase>190.49</tripAdultBase><tripAdultTax>28.49</tripAdultTax><tripSeniorBase>0</tripSeniorBase><tripSeniorTax>0</tripSeniorTax><tripYouthBase>0</tripYouthBase><tripYouthTax>0</tripYouthTax><tripChildBase>0</tripChildBase><tripChildTax>0</tripChildTax><tripInfantBase>0</tripInfantBase><tripInfantTax>0</tripInfantTax><tripInfantWithSeatBase>0</tripInfantWithSeatBase><tripInfantWithSeatTax>0</tripInfantWithSeatTax><tripAirResponseTaxes><tripAirResponseTax><amount>4.1</amount><designator></designator><nature></nature><description>Segment Fee</description></tripAirResponseTax><tripAirResponseTax><amount>5.6</amount><designator></designator><nature></nature><description>Passenger Facility Charge</description></tripAirResponseTax><tripAirResponseTax><amount>14.29</amount><designator></designator><nature></nature><description>Excise Tax</description></tripAirResponseTax><tripAirResponseTax><amount>4.5</amount><designator></designator><nature></nature><description>September 11th Security Fee</description></tripAirResponseTax><tripAirResponseTax><amount>5</amount><designator></designator><nature></nature><description>BOOKING CHARGE</description></tripAirResponseTax></tripAirResponseTaxes></TripAirPrice><TripAirPrice><tripCategory>Search</tripCategory><tripAdultBase>190.49</tripAdultBase><tripAdultTax>28.49</tripAdultTax><tripSeniorBase>0</tripSeniorBase><tripSeniorTax>0</tripSeniorTax><tripYouthBase>0</tripYouthBase><tripYouthTax>0</tripYouthTax><tripChildBase>0</tripChildBase><tripChildTax>0</tripChildTax><tripInfantBase>0</tripInfantBase><tripInfantTax>0</tripInfantTax><tripInfantWithSeatBase>0</tripInfantWithSeatBase><tripInfantWithSeatTax>0</tripInfantWithSeatTax></TripAirPrice></TripAirPrices><TripAirResponse><searchAirPrice>190.49</searchAirPrice><searchAirTax>28.49</searchAirTax><actualAirPrice>190.49</actualAirPrice><actualAirTax>28.49</actualAirTax><bookingcharges>5</bookingcharges><appliedDiscount>0</appliedDiscount><repricedAirPrice>190.49</repricedAirPrice><repricedAirTax>28.49</repricedAirTax><CurrencyCodeKey>USD</CurrencyCodeKey><isSplit>False</isSplit><agentWareQueryID>122167828</agentWareQueryID><agentwareItineraryID>916163292</agentwareItineraryID><TripAirLegs><TripAirSegments><TripAirLeg><gdsSourceKey>12</gdsSourceKey><selectedBrand></selectedBrand><recordLocator></recordLocator><airLegNumber>1</airLegNumber><validatingCarrier>WN</validatingCarrier><contractCode></contractCode><isRefundable>True</isRefundable><TripAirLegPassengerInfos><TripAirLegPassengerInfo><PassengerKey>562934</PassengerKey><ticketNumber>5268524561592</ticketNumber><InvoiceNumber></InvoiceNumber></TripAirLegPassengerInfo></TripAirLegPassengerInfos></TripAirLeg><TripAirSegment><airSegmentKey>d428a637-dd3d-4f6c-b016-272a81e86ef1</airSegmentKey><airLegNumber>1</airLegNumber><airSegmentMarketingAirlineCode>WN</airSegmentMarketingAirlineCode><airSegmentOperatingAirlineCode>WN</airSegmentOperatingAirlineCode><airSegmentFlightNumber>4008</airSegmentFlightNumber><airSegmentDuration>01:25:00</airSegmentDuration><airSegmentEquipment></airSegmentEquipment><airSegmentMiles>0</airSegmentMiles><airSegmentDepartureDate>10/15/2017 8:45:00 AM</airSegmentDepartureDate><airSegmentArrivalDate>10/15/2017 10:10:00 AM</airSegmentArrivalDate><airSegmentDepartureAirport>SFO</airSegmentDepartureAirport><airSegmentArrivalAirport>LAX</airSegmentArrivalAirport><airSegmentResBookDesigCode>Y</airSegmentResBookDesigCode><airSegmentDepartureOffset>0</airSegmentDepartureOffset><airSegmentArrivalOffset>0</airSegmentArrivalOffset><airSegmentSeatRemaining>0</airSegmentSeatRemaining><airSegmentMarriageGrp>          </airSegmentMarriageGrp><airFareBasisCode></airFareBasisCode><airFareReferenceKey></airFareReferenceKey><airSelectedSeatNumber></airSelectedSeatNumber><airsegmentcabin>Economy</airsegmentcabin><ticketNumber></ticketNumber><airSegmentOperatingFlightNumber>4008</airSegmentOperatingFlightNumber><RecordLocator>U2HI6S</RecordLocator><RPH>0</RPH><airSegmentOperatingAirlineCompanyShortName></airSegmentOperatingAirlineCompanyShortName><DepartureTerminal></DepartureTerminal><ArrivalTerminal></ArrivalTerminal><PNRNo>2727401</PNRNo><airSegmentBrandName>Anytime</airSegmentBrandName><TripAirSegmentPassengersInfo><TripAirSegmentPassengerInfo><PassengerKey>562934</PassengerKey><airFareBasisCode></airFareBasisCode><airSelectedSeatNumber></airSelectedSeatNumber><seatMapStatus></seatMapStatus></TripAirSegmentPassengerInfo></TripAirSegmentPassengersInfo></TripAirSegment></TripAirSegments></TripAirLegs><TripPolicyExceptions><TripPolicyException><TripRequestKey>521370</TripRequestKey><TimeBandTotalThresholdAmt>0</TimeBandTotalThresholdAmt><AlternateAirportTotalThresholdAmt>0</AlternateAirportTotalThresholdAmt><AdvancePurchaseAirportTotalThresholdAmt>0</AdvancePurchaseAirportTotalThresholdAmt><penaltyFareTotalThresholdAmt>0</penaltyFareTotalThresholdAmt><xConnectionsPolicyTotalThresholdAmt>0</xConnectionsPolicyTotalThresholdAmt><lowestPriceOfTrip>0</lowestPriceOfTrip><ReasonCode>229</ReasonCode><PolicyKey>2482</PolicyKey><ReasonDescription>OOP</ReasonDescription><thresholdamt>0</thresholdamt><LowFarePolicyAmt>0</LowFarePolicyAmt><LowestAmtFromAllPolicy>0</LowestAmtFromAllPolicy><TripHistoryKey>00000000-0000-0000-0000-000000000000</TripHistoryKey></TripPolicyException></TripPolicyExceptions></TripAirResponse></Air></TripComponents><SaveTrip><Trip><tripName>Trip-OFXWCH</tripName><userKey>562934</userKey><recordLocator>OFXWCH</recordLocator><tripStatusKey>1</tripStatusKey><agencyKey>1</agencyKey><siteKey>51</siteKey><tripComponentType>1</tripComponentType><tripRequestKey>521370</tripRequestKey><meetingCodeKey></meetingCodeKey><tripAdultsCount>1</tripAdultsCount><tripSeniorsCount>0</tripSeniorsCount><tripChildCount>0</tripChildCount><tripInfantCount>0</tripInfantCount><tripYouthCount>0</tripYouthCount><tripInfantWithSeatCount>0</tripInfantWithSeatCount><noOfTotalTraveler>1</noOfTotalTraveler><noOfRooms>0</noOfRooms><noOfCars>0</noOfCars><isAudit>False</isAudit><tripCreationPath>2</tripCreationPath><TrackingLogID>0</TrackingLogID><bookingFeeARC></bookingFeeARC><Issue_Date>9/5/2017 1:08:10 PM</Issue_Date><SabreCreationDate>9/5/2017 1:08:10 PM</SabreCreationDate><groupKey>1004</groupKey><EventKey></EventKey><AttendeeGuid></AttendeeGuid><UserIPAddress>::1</UserIPAddress><SessionId>1njpcefwvm54al2yx31yqv2e</SessionId><subsiteKey></subsiteKey><isArrangerBookForGuest>False</isArrangerBookForGuest><FailureReason></FailureReason></Trip><UpdateTrip><tripTotalBaseCost>190.49</tripTotalBaseCost><tripTotalTaxCost>28.49</tripTotalTaxCost><startdate>10/15/2017 8:45:00 AM</startdate><enddate>10/15/2017 8:45:00 AM</enddate><bookingCharges>5</bookingCharges><isOnlineBooking>True</isOnlineBooking></UpdateTrip><TripConfirmationFriendEmails /></SaveTrip></SavePurchasedTrip>'
-- EXEC [dbo].[SavePurchaseTrip_Purchase] @xmldata
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_Purchase] 
	-- Add the parameters for the stored procedure here
	@xml XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--BEGIN TRANSACTION
BEGIN TRY
	
	Declare @TripPurchaseKey uniqueidentifier = NULL
	Declare @TripSavedKey uniqueidentifier = NULL
	Declare @tripId int
	
	IF (SELECT 1 FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/TripSaved')AS TEMPTABLE(TripSaved)) > 0
	BEGIN
		SET @TripSavedKey = NEWID()
		INSERT INTO [dbo].[TripSaved](tripSavedKey,userKey,createdDate)
		SELECT @TripSavedKey,  
		TripSaved.value('(userKey/text())[1]','int') AS userKey,
		getdate()  
		FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/TripSaved')AS TEMPTABLE(TripSaved)
	END
	ELSE
	BEGIN
		SET @TripPurchaseKey = NEWID()
		Insert into [dbo].[TripPurchased] (tripPurchasedKey) values (@TripPurchaseKey)	
	END
	
	INSERT INTO [dbo].[Trip] ([tripPurchasedKey],[tripSavedKey],[tripName],[userKey],[recordLocator],[tripStatusKey] ,[agencyKey],tripComponentType,tripRequestKey,
		meetingCodeKey,sitekey,tripAdultsCount,tripSeniorsCount,tripChildCount,tripYouthCount,tripInfantCount,tripInfantWithSeatCount,noOfTotalTraveler,
		noOfRooms,noOfCars,ModifiedDateTime,isAudit,tripCreationPath,TrackingLogID,bookingFeeARC, IssueDate,SabreCreationDate,groupKey,EventKey,
		AttendeeGuid,UserIPAddress,SessionId,subsiteKey,isArrangerBookForGuest,FailureReason, Culture, AncillaryServices, AncillaryFees,isGroupBooking, isUserCreatedSavedTrip, 
		IsRequestApproval,ApproverEmailAddresses,IsRequestNotification, NotificationEmailAddresses,ApprovalReasons,NotificationReasons,BackupApproverEmails,AdvantageNumber,CartNumber,DKNumber,cross_reference_trip_id,[type],isUpgradeBooking)
	SELECT @TripPurchaseKey,@TripSavedKey,
	  Trip.value('(tripName/text())[1]','VARCHAR(50)') AS tripName,
	  Trip.value('(userKey/text())[1]','int') AS userKey,
	  Trip.value('(recordLocator/text())[1]','VARCHAR(50)') AS recordLocator,
	  Trip.value('(tripStatusKey/text())[1]','int') AS tripStatusKey,	  
	  Trip.value('(agencyKey/text())[1]','int') AS agencyKey,
	  Trip.value('(tripComponentType/text())[1]','int') AS tripComponentType,
	  Trip.value('(tripRequestKey/text())[1]','int') AS tripRequestKey,
	  Trip.value('(meetingCodeKey/text())[1]','VARCHAR(50)') AS meetingCodeKey,
	  Trip.value('(siteKey/text())[1]','int') AS siteKey,
	  Trip.value('(tripAdultsCount/text())[1]','int') AS tripAdultsCount,
	  Trip.value('(tripSeniorsCount/text())[1]','int') AS tripSeniorsCount,
	  Trip.value('(tripChildCount/text())[1]','int') AS tripChildCount,
	  Trip.value('(tripYouthCount/text())[1]','int') AS tripYouthCount,
	  Trip.value('(tripInfantCount/text())[1]','int') AS tripInfantCount,
	  Trip.value('(tripInfantWithSeatCount/text())[1]','int') AS tripInfantWithSeatCount,
	  Trip.value('(noOfTotalTraveler/text())[1]','int') AS noOfTotalTraveler,
	  Trip.value('(noOfRooms/text())[1]','int') AS noOfRooms,
	  Trip.value('(noOfCars/text())[1]','int') AS noOfCars,
	  GETDATE(),
	  Trip.value('(isAudit/text())[1]','bit') AS isAudit,
	  Trip.value('(tripCreationPath/text())[1]','int') AS tripCreationPath,
	  Trip.value('(TrackingLogID/text())[1]','int') AS TrackingLogID,
	  Trip.value('(bookingFeeARC/text())[1]','VARCHAR(20)') AS bookingFeeARC,
	  (case when (charindex('-', Trip.value('(Issue_Date/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, Trip.value('(Issue_Date/text())[1]','VARCHAR(30)'), 103) 
			else Trip.value('(Issue_Date/text())[1]','datetime') end) AS Issue_Date,
	  (case when (charindex('-', Trip.value('(SabreCreationDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, Trip.value('(SabreCreationDate/text())[1]','VARCHAR(30)'), 103) 
			else Trip.value('(SabreCreationDate/text())[1]','datetime') end) AS SabreCreationDate,
	  Trip.value('(groupKey/text())[1]','int') AS groupKey,
	  Trip.value('(EventKey/text())[1]','int') AS EventKey,
	  Trip.value('(AttendeeGuid/text())[1]','VARCHAR(100)') AS AttendeeGuid,
	  Trip.value('(UserIPAddress/text())[1]','VARCHAR(50)') AS UserIPAddress,
	  Trip.value('(SessionId/text())[1]','VARCHAR(300)') AS SessionId,
	  Trip.value('(subsiteKey/text())[1]','int') AS subsiteKey,
	  Trip.value('(isArrangerBookForGuest/text())[1]','bit') AS isArrangerBookForGuest,
	  Trip.value('(FailureReason/text())[1]','VARCHAR(4000)') AS FailureReason,
	  Trip.value('(Culture/text())[1]','VARCHAR(50)') AS Culture,
	  Trip.value('(AncillaryServices/text())[1]','VARCHAR(50)') AS AncillaryServices,
	  Trip.value('(AncillaryFees/text())[1]','float') AS AncillaryFees,
	  Trip.value('(isGroupBooking/text())[1]','bit') AS isGroupBooking,
	  Trip.value('(isUserCreatedSavedTrip/text())[1]','bit') AS isUserCreatedSavedTrip,
	  Trip.value('(IsRequestApproval/text())[1]','bit') AS IsRequestApproval,
	  Trip.value('(ApproverEmailAddresses/text())[1]','NVARCHAR(MAX)') AS ApproverEmailAddresses,
	  Trip.value('(IsRequestNotification/text())[1]','bit') AS IsRequestNotification,
	  Trip.value('(NotificationEmailAddresses/text())[1]','NVARCHAR(MAX)') AS NotificationEmailAddresses,
	  Trip.value('(ApprovalReasons/text())[1]','NVARCHAR(MAX)') AS ApprovalReasons,
	  Trip.value('(NotificationReasons/text())[1]','NVARCHAR(MAX)') AS NotificationReasons,
	  Trip.value('(BackupApproverEmails/text())[1]','NVARCHAR(MAX)') AS BackupApproverEmails,
	  Trip.value('(AdvantageNumber/text())[1]','NVARCHAR(200)') AS AdvantageNumber,
	  Trip.value('(CartNumber/text())[1]','NVARCHAR(200)') AS CartNumber,
	  Trip.value('(DKNumber/text())[1]','NVARCHAR(20)') AS DKNumber,
	  Trip.value('(CrossReferenceTripId/text())[1]','int') AS cross_reference_trip_id,
	  Trip.value('(type/text())[1]','NVARCHAR(20)') AS [type],
	  Trip.value('(isUpgradeBooking/text())[1]','tinyint') AS isUpgradeBooking
	FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(Trip)
				
	SET @tripId = scope_identity()
	
	INSERT INTO [TripStatusHistory] ([tripKey],[tripStatusKey],[createdDateTime])
	SELECT @tripId,  
	  TripStatusHistory.value('(tripStatusKey/text())[1]','int') AS tripStatusKey,
	  getdate()  
	FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(TripStatusHistory)
	
	SET @TripPurchaseKey = ISNULL(@TripPurchaseKey,@TripSavedKey);

	---------------Passenger Info-----------------
	declare @xmlTripPassenger xml, @TripPassenger SavePurchaseTrip_TripPassenger
	select @xmlTripPassenger = @xml.query('/SavePurchasedTrip/TripPassenger')
	INSERT INTO @TripPassenger EXEC [dbo].[SavePurchaseTrip_TripPassenger_Insert] @xmlTripPassenger, @TripPurchaseKey, @tripId	  
		  
	---------------Travel Component-----------------	  
	declare @xmlTripAir xml
	select @xmlTripAir = @xml.query('/SavePurchasedTrip/TripComponents/Air')
	EXEC [dbo].[SavePurchaseTrip_TravelComponent_Air_Insert] @xmlTripAir, @TripPurchaseKey, @tripId, @TripPassenger
	
	declare @xmlTripHotel xml
	select @xmlTripHotel = @xml.query('/SavePurchasedTrip/TripComponents/Hotel')
	EXEC [dbo].[SavePurchaseTrip_TravelComponent_Hotel_Insert] @xmlTripHotel, @TripPurchaseKey, @tripId, @TripPassenger

	declare @xmlTripCar xml
	select @xmlTripCar = @xml.query('/SavePurchasedTrip/TripComponents/Car')
	EXEC [dbo].[SavePurchaseTrip_TravelComponent_Car_Insert] @xmlTripCar, @TripPurchaseKey,@tripId, @TripPassenger
	
	declare @xmlTripCruise xml
	select @xmlTripCruise = @xml.query('/SavePurchasedTrip/TripComponents/Cruise')
	EXEC [dbo].[SavePurchaseTrip_TravelComponent_Cruise_Insert] @xmlTripCruise, @TripPurchaseKey, @tripId
	
	declare @xmlTripActivity xml
	select @xmlTripActivity = @xml.query('/SavePurchasedTrip/TripComponents/Activity')
	EXEC [dbo].[SavePurchaseTrip_TravelComponent_Activity_Insert] @xmlTripActivity, @TripPurchaseKey, @tripId, @TripPassenger
	
	declare @xmlTripRail xml
	select @xmlTripRail = @xml.query('/SavePurchasedTrip/TripComponents/Rail')
	EXEC [dbo].[SavePurchaseTrip_TravelComponent_Rail_Insert] @xmlTripRail, @TripPurchaseKey, @tripId, @TripPassenger
		
	--EXEC [dbo].[USP_AddTripPromotionHistory]  
	INSERT INTO [Trip].[dbo].[TripPromotionHistory] ([PromoId],[PromoCampaignName],[PublicCode],[PromoCampaignType],[DiscountRate],[UsageRestriction]          
			   ,[OfferMatchType],[HotelVenorMatch],[HotelChainMatch],[HotelGroupMatch],[CitySpecificMatch],[SpecificAirportCodeMatch],[PurchaseStart],[PuchaseEnd]          
			   ,[TravelDateStart],[TravelDateEnd],[MinimumNightStayRequirement],[MinimumSpendRequirement],[PromoCodeApplied],[IsTravelAirCarHotelEligible]        
			   ,[IsAirHoteEligible],[IsHotelOnlyEligible],[IsAllActivtyEligible],[IsTravelToMexicoEligible],[IsTravelToCaribbeanEligible]        
			   ,[IsTravelToEuropeEligible],[IsTravelToSouthAmericaEligible],[UserKey],[CreateDate],[ModifiedDate],[CitySpecificMatchKey],[TripGuidKey],[PromotionDiscount])
		SELECT TripPromotionHistory.value('(PromoId/text())[1]','int') AS PromoId,  
		TripPromotionHistory.value('(PromoCampaignName/text())[1]','VARCHAR(50)') AS PromoCampaignName,
		TripPromotionHistory.value('(PublicCode/text())[1]','VARCHAR(100)') AS PublicCode,
		TripPromotionHistory.value('(PromoCampaignType/text())[1]','VARCHAR(100)') AS PromoCampaignType,
		TripPromotionHistory.value('(DiscountRate/text())[1]','VARCHAR(10)') AS DiscountRate,
		TripPromotionHistory.value('(UsageRestriction/text())[1]','VARCHAR(20)') AS UsageRestriction,
		TripPromotionHistory.value('(OfferMatchType/text())[1]','VARCHAR(100)') AS OfferMatchType,
		TripPromotionHistory.value('(HotelVendorMatch/text())[1]','VARCHAR(50)') AS HotelVendorMatch,
		TripPromotionHistory.value('(HotelChainMatch/text())[1]','VARCHAR(50)') AS HotelChainMatch,
		TripPromotionHistory.value('(HotelGroupMatch/text())[1]','VARCHAR(50)') AS HotelGroupMatch,
		TripPromotionHistory.value('(CitySpecificMatch/text())[1]','VARCHAR(50)') AS CitySpecificMatch,
		TripPromotionHistory.value('(SpecificAirportCodeMatch/text())[1]','VARCHAR(50)') AS SpecificAirportCodeMatch,
		(case when (charindex('-', TripPromotionHistory.value('(PurchaseStart/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripPromotionHistory.value('(PurchaseStart/text())[1]','VARCHAR(30)'), 103) 
			else TripPromotionHistory.value('(PurchaseStart/text())[1]','datetime') end) AS PurchaseStart,
		(case when (charindex('-', TripPromotionHistory.value('(PurchaseEnd/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripPromotionHistory.value('(PurchaseEnd/text())[1]','VARCHAR(30)'), 103) 
			else TripPromotionHistory.value('(PurchaseEnd/text())[1]','datetime') end) AS PurchaseEnd,
		(case when (charindex('-', TripPromotionHistory.value('(TravelDateStart/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripPromotionHistory.value('(TravelDateStart/text())[1]','VARCHAR(30)'), 103) 
			else TripPromotionHistory.value('(TravelDateStart/text())[1]','datetime') end) AS TravelDateStart,
		(case when (charindex('-', TripPromotionHistory.value('(TravelDateEnd/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripPromotionHistory.value('(TravelDateEnd/text())[1]','VARCHAR(30)'), 103) 
			else TripPromotionHistory.value('(TravelDateEnd/text())[1]','datetime') end) AS TravelDateEnd,	
		TripPromotionHistory.value('(MinimumNightStayRequirement/text())[1]','VARCHAR(50)') AS MinimumNightStayRequirement,
		TripPromotionHistory.value('(MinimumSpendRequirement/text())[1]','VARCHAR(50)') AS MinimumSpendRequirement,
		TripPromotionHistory.value('(PromoCodeApplied/text())[1]','VARCHAR(20)') AS PromoCodeApplied,
		TripPromotionHistory.value('(IsTravelAirCarHotelEligible/text())[1]','bit') AS IsTravelAirCarHotelEligible,	
		TripPromotionHistory.value('(IsAirHoteEligible/text())[1]','bit') AS IsAirHoteEligible,	
		TripPromotionHistory.value('(IsHotelOnlyEligible/text())[1]','bit') AS IsHotelOnlyEligible,	
		TripPromotionHistory.value('(IsAllActivtyEligible/text())[1]','bit') AS IsAllActivtyEligible,	
		TripPromotionHistory.value('(IsTravelToMexicoEligible/text())[1]','bit') AS IsTravelToMexicoEligible,	
		TripPromotionHistory.value('(IsTravelToCaribbeanEligible/text())[1]','bit') AS IsTravelToCaribbeanEligible,	
		TripPromotionHistory.value('(IsTravelToEuropeEligible/text())[1]','bit') AS IsTravelToEuropeEligible,	
		TripPromotionHistory.value('(IsTravelToSouthAmericaEligible/text())[1]','bit') AS IsTravelToSouthAmericaEligible,			
		TripPromotionHistory.value('(UserKey/text())[1]','VARCHAR(10)') AS UserKey, GETDATE(), GETDATE(),
		TripPromotionHistory.value('(CitySpecificMatchKey/text())[1]','VARCHAR(10)') AS CitySpecificMatchKey,
		@TripPurchaseKey,
		TripPromotionHistory.value('(PromotionDiscount/text())[1]','float') AS PromotionDiscount  
	FROM @xml.nodes('/SavePurchasedTrip/TripComponents/Promotion')AS TEMPTABLE(TripPromotionHistory)
	---------------Travel Component-----------------	  
	
	UPDATE T SET T.tripTotalBaseCost = X.tripTotalBaseCost, T.tripTotalTaxCost = X.tripTotalTaxCost, 
				T.tripOriginalTotalBaseCost = X.tripOriginalTotalBaseCost, T.tripOriginalTotalTaxCost = X.tripOriginalTotalTaxCost,
				T.startdate = X.startdate, T.enddate = X.enddate,
				T.bookingCharges = X.bookingCharges, T.isOnlineBooking = X.isOnlineBooking FROM [dbo].[Trip] T 
		INNER JOIN (SELECT @tripId as tripId, 
							UpdateTrip.value('(tripTotalBaseCost/text())[1]','float') AS tripTotalBaseCost,
							UpdateTrip.value('(tripTotalTaxCost/text())[1]','float') AS tripTotalTaxCost,
							UpdateTrip.value('(tripOriginalTotalBaseCost/text())[1]','float') AS tripOriginalTotalBaseCost,
							UpdateTrip.value('(tripOriginalTotalTaxCost/text())[1]','float') AS tripOriginalTotalTaxCost,
							(case when (charindex('-', UpdateTrip.value('(startdate/text())[1]','VARCHAR(30)')) > 0) 
								then CONVERT(datetime, UpdateTrip.value('(startdate/text())[1]','VARCHAR(30)'), 103) 
								else UpdateTrip.value('(startdate/text())[1]','datetime') end) AS startdate,
							(case when (charindex('-', UpdateTrip.value('(enddate/text())[1]','VARCHAR(30)')) > 0) 
								then CONVERT(datetime, UpdateTrip.value('(enddate/text())[1]','VARCHAR(30)'), 103) 
								else UpdateTrip.value('(enddate/text())[1]','datetime') end) AS enddate,
							UpdateTrip.value('(bookingCharges/text())[1]','float') AS bookingCharges,
							UpdateTrip.value('(isOnlineBooking/text())[1]','bit') AS isOnlineBooking
					FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/UpdateTrip')AS TEMPTABLE(UpdateTrip))X ON T.tripKey = X.tripId 

	if(@TripSavedKey is not null)
	begin
	declare @tripSavedReferenceId varchar(50)
	exec USP_Get_TripSavedReferenceId_Random @tripid, @tripSavedReferenceId output
	update Trip..Trip set tripSavedReferenceId= @tripSavedReferenceId,recordLocator=@tripSavedReferenceId where tripKey=@tripid
	end
	
	INSERT INTO [TripConfirmationFriendEmail] ([tripKey],[friendEmailAddress]) 
	SELECT @tripId,  
	  TripConfirmationFriendEmail.value('(FriendEmailAddress/text())[1]','VARCHAR(100)') AS FriendEmailAddress
	FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/TripConfirmationFriendEmails/TripConfirmationFriendEmail')AS TEMPTABLE(TripConfirmationFriendEmail)
	
	---------------Trip Ticket Info-----------------
	/* Condition for same ticket is exist or not */
	Declare @tripKey int, @isExchanged bit, @isVoided bit, @isRefunded bit, @oldTicketNumber varchar(20)
	Select @tripKey = TripTicketInfo.value('(tripKey/text())[1]','int'),
		  @isExchanged = TripTicketInfo.value('(isExchanged/text())[1]','bit'),
		  @isVoided = TripTicketInfo.value('(isVoided/text())[1]','bit'),
		  @isRefunded = TripTicketInfo.value('(isRefunded/text())[1]','bit'),
		  @oldTicketNumber = TripTicketInfo.value('(oldTicketNumber/text())[1]','VARCHAR(20)')         
		FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo)
		
	IF(SELECT COUNT(*) FROM TripTicketInfo WITH(NOLOCK)
			WHERE tripKey = @tripId AND isExchanged = @isExchanged	AND isVoided = @isVoided AND isRefunded = @isRefunded 
					AND oldTicketNumber = @oldTicketNumber) = 0
	BEGIN 
		INSERT INTO TripTicketInfo (tripKey, recordLocator, isExchanged, isVoided, isRefunded, oldTicketNumber, newTicketNumber, createdDate, issuedDate,
				currency, oldFare, newFare, addCollectFare, serviceCharge, residualFare, TotalFare, ExchangeFee, BaseFare, TaxFare, IsHostStatusTicketed)
		SELECT @tripId,		  
			  TripTicketInfo.value('(recordLocator/text())[1]','VARCHAR(10)') AS recordLocator,
			  @isExchanged, @isVoided, @isRefunded, 
			  TripTicketInfo.value('(oldTicketNumber/text())[1]','VARCHAR(20)') AS oldTicketNumber,
			  TripTicketInfo.value('(newTicketNumber/text())[1]','VARCHAR(20)') AS newTicketNumber,
			  GETDATE(),
			  (case when (charindex('-', TripTicketInfo.value('(issuedDate/text())[1]','VARCHAR(30)')) > 0) 
					then CONVERT(datetime, TripTicketInfo.value('(issuedDate/text())[1]','VARCHAR(30)'), 103) 
					else TripTicketInfo.value('(issuedDate/text())[1]','datetime') end) AS issuedDate,
			  TripTicketInfo.value('(currency/text())[1]','VARCHAR(10)') AS currency,
			  TripTicketInfo.value('(oldFare/text())[1]','float') AS oldFare,
			  TripTicketInfo.value('(newFare/text())[1]','float') AS newFare,
			  TripTicketInfo.value('(addCollectFare/text())[1]','float') AS addCollectFare,
			  TripTicketInfo.value('(serviceCharge/text())[1]','float') AS serviceCharge,
			  TripTicketInfo.value('(residualFare/text())[1]','float') AS residualFare,
			  TripTicketInfo.value('(TotalFare/text())[1]','float') AS TotalFare,
			  TripTicketInfo.value('(ExchangeFee/text())[1]','float') AS ExchangeFee,
			  TripTicketInfo.value('(BaseFare/text())[1]','float') AS BaseFare,
			  TripTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare,
			  TripTicketInfo.value('(isHostStatusTicketed/text())[1]','bit') as IsHostStatusTicketed
		FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo)
	END
	
	---------------Trip EMD Ticket Info-----------------
	INSERT INTO TripEMDTicketInfo (tripKey, recordLocator, DocumentNumber, TotalFare, TotalBaseFare, TotalTaxFare,FlightNumber, createdDate, AirlineCode, SeatNumber, IssuedDate)
		SELECT @tripId,		  
			  TripEMDTicketInfo.value('(recordLocator/text())[1]','VARCHAR(10)') AS recordLocator,
			  TripEMDTicketInfo.value('(DocumentNumber/text())[1]','VARCHAR(20)') AS DocumentNumber,
			  TripEMDTicketInfo.value('(TotalFare/text())[1]','float') AS TotalFare,
			  TripEMDTicketInfo.value('(BaseFare/text())[1]','float') AS BaseFare,
			  TripEMDTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare,
			  TripEMDTicketInfo.value('(FlightNumber/text())[1]','VARCHAR(20)') AS FlightNumber,    
			  GETDATE(),
			  TripEMDTicketInfo.value('(AirlineCode/text())[1]','VARCHAR(2)') AS AirlineCode, 
			  TripEMDTicketInfo.value('(SeatNumber/text())[1]','VARCHAR(10)') AS SeatNumber,
			  TripEMDTicketInfo.value('(IssuedDate/text())[1]','datetime') AS IssuedDate 
		FROM @xml.nodes('/SavePurchasedTrip/TripEMDTicketInfos/EMDTicketInfo')AS TEMPTABLE(TripEMDTicketInfo)
	

	--------------------- trip ancillary services ----------------------------------------------------

		INSERT INTO trip..TripAncillaryServices(TripKey,TypeOfAncillary,InvoiceNo,MaskedCardNo,ServiceFeeVendorCode,TotalAmountCharged,CreatedDate,DocumentNo,InvoiceDateTime,IsXAC,NameOnCard)
		SELECT @tripId,		  
			  TripAncillaryServiceInfo.value('(typeOfAncillary/text())[1]','int') AS TypeOfAncillary,
			  TripAncillaryServiceInfo.value('(invoiceNo/text())[1]','VARCHAR(20)') AS InvoiceNo,
			  TripAncillaryServiceInfo.value('(maskedCardNo/text())[1]','VARCHAR(20)') AS MaskedCardNo,
			  TripAncillaryServiceInfo.value('(serviceFeeVendorCode/text())[1]','float') AS ServiceFeeVendorCode,
			  TripAncillaryServiceInfo.value('(totalAmountCharged/text())[1]','float') AS TotalAmountCharged,
			  GETDATE() as CreatedDate,
			  TripAncillaryServiceInfo.value('(documentNo/text())[1]','VARCHAR(20)') as DocumentNo,
			  (case when (charindex('-', TripAncillaryServiceInfo.value('(invoiceDateTime/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripAncillaryServiceInfo.value('(invoiceDateTime/text())[1]','VARCHAR(30)'), 103) 
			else TripAncillaryServiceInfo.value('(invoiceDateTime/text())[1]','datetime') end) as InvoiceDateTime,
			   TripAncillaryServiceInfo.value('(isXAC/text())[1]','bit') AS IsXAC,
			     TripAncillaryServiceInfo.value('(nameOnCard/text())[1]','nvarchar(1000)') AS NameOnCard
		  	FROM @xml.nodes('/SavePurchasedTrip/TripAncillaryServicesInfo/TripAncillaryServiceInfo')AS TEMPTABLE(TripAncillaryServiceInfo)
		--------------------- trip ancillary services end ----------------------------------------------------
	select @tripId
	--COMMIT TRANSACTION;
	--print 'Commit'
END TRY
BEGIN CATCH

	Declare @Userkey    [INT] = 0,    
			@TripRequestkey   [INT] = 0,    
			@Type     [VARCHAR](100)= '',    
			@WSName     [VARCHAR](50) = '',    
			@XmlData    [XML] = '',    
			@Event     [VARCHAR](500) = '',    
			@Details    [VARCHAR](1000) = '' ,    
			@ExceptionMessage  [VARCHAR](max)  = '',    
			@StackTrace    [VARCHAR](max)  = '',    
			@SessionId    [VARCHAR](200)  = '',    
			@LogLevelKey   [INT]  = 0,    
			@Comment    [VARCHAR](500)  = '',    
			@URL     [VARCHAR](1000)  = '',
			@SingleBookThreadId [nvarchar](50) ='',
			@GroupBookThreadId [nvarchar](50)='' 

SELECT @Userkey = Trip.value('(userKey/text())[1]','int'),
	  @TripRequestkey = Trip.value('(tripRequestKey/text())[1]','int'),
	  @Type = 'StoredProcedure', @WSName = 'SavePurchaseTrip_Purchase',
	  @XmlData = @xml, @Event = '', @Details = '',
	  @ExceptionMessage = ERROR_MESSAGE(),
	  @StackTrace = ERROR_STATE(),
	  @SessionId = ERROR_NUMBER(),
	  @LogLevelKey = ERROR_LINE(),
	  @Comment = ERROR_SEVERITY(),
	  @URL = '',
	  @SingleBookThreadId = '',
	  @GroupBookThreadId =''
	FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(Trip)

	--SELECT   
 --       ERROR_NUMBER() AS ErrorNumber  
 --       ,ERROR_SEVERITY() AS ErrorSeverity  
 --       ,ERROR_STATE() AS ErrorState  
 --       ,ERROR_PROCEDURE() AS ErrorProcedure  
 --       ,ERROR_LINE() AS ErrorLine  
 --       ,ERROR_MESSAGE() AS ErrorMessage;
	--ROLLBACK TRANSACTION;
	--print 'Rollback'
	Exec [Log].[dbo].[USP_InsertLogs] @Userkey, @TripRequestkey, @Type, @WSName, @XmlData, @Event, @Details, @ExceptionMessage, @StackTrace, @SessionId, @LogLevelKey, @Comment, @URL, @SingleBookThreadId, @GroupBookThreadId

END CATCH
	
END
GO
