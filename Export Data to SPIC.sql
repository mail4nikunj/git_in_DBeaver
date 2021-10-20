--SELECT count(1) FROM "tblMOPaymentDetails" tmd WHERE "intPaymentStatus" = 2 AND "dteCreatedOn"::DATE >= '2021-08-25'::DATE AND "dteCreatedOn"::DATE <= '2021-10-08'::DATE  
--COmment
(		
			--TopUp
			SELECT 
				MP."intMOTransactionID" AS "AppRefNo",
				MP."intTransactionAmount"/100 as "TransactionAmount",
				CASE 
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSREC' THEN 'Top-up'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSANN' AND MP."intMOTransactionTypeID" = 5 THEN 'New Application- Anonymous'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSPER' AND MP."intMOTransactionTypeID" = 5 THEN 'New Application- Personalized'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSANN' AND MP."intMOTransactionTypeID" = 6 THEN 'Replacement- Anonymous'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSPER' AND MP."intMOTransactionTypeID" = 6 THEN 'Replacement - Personalized'
				ELSE tpgscc."strServiceCode" END AS "ServiceCode",
				MP."dteCreatedOn"::DATE AS "Date"
			FROM 
				"tblMOPaymentDetails" MP
				
				INNER JOIN "tblOnlineSmartCardTopUpPG" tosctup 
				ON tosctup."intOTopUpTransactionID" = MP."intMOTransactionID"
				
				INNER JOIN "tblCards" TC ON 				
				TC."intCardID" = tosctup."intCardID"
				
				INNER JOIN "tblPaymentGatewayServiceCodeConfig" tpgscc
				ON tpgscc."intPaymentGatewayID" = MP."intPaymentGatewayID"
				AND tpgscc."intTransactionTypeID" = MP."intMOTransactionTypeID"
				AND tpgscc."intCardTypeID"  = TC."intSmartCardTypeID"				
				
			WHERE  
				MP."intPaymentStatus" = 2  
				AND MP."intPGRefNo" IS NOT NULL 
				AND (MP."intPaymentGatewayID" = 1)
				AND MP."dteCreatedOn" > '2021-08-25 00:00:00' AND MP."dteCreatedOn" < '2021-10-08 23:59:59' 
			ORDER BY MP."dteCreatedOn" DESC --LIMIT 1
		)
		UNION ALL 
		(
			--New Card
			SELECT 
				MP."intMOTransactionID" AS "AppRefNo",
				MP."intTransactionAmount"/100 as "intTransactionAmount",
				CASE 
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSREC' THEN 'Top-up'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSANN' AND MP."intMOTransactionTypeID" = 5 THEN 'New Application- Anonymous'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSPER' AND MP."intMOTransactionTypeID" = 5 THEN 'New Application- Personalized'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSANN' AND MP."intMOTransactionTypeID" = 6 THEN 'Replacement- Anonymous'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSPER' AND MP."intMOTransactionTypeID" = 6 THEN 'Replacement - Personalized'
				ELSE tpgscc."strServiceCode" END AS "ServiceCode",
				MP."dteCreatedOn"::DATE AS "Date"
			FROM 
				"tblMOPaymentDetails" MP
				
				INNER JOIN "tblNewCardIssueRequest" tncir 
				ON tncir."strRequestRefNo" = MP."intMOTransactionID"::CHARACTER VARYING 
				
				INNER JOIN "tblPaymentGatewayServiceCodeConfig" tpgscc
				ON tpgscc."intPaymentGatewayID" = MP."intPaymentGatewayID"
				AND tpgscc."intTransactionTypeID" = MP."intMOTransactionTypeID"
				AND tpgscc."intCardTypeID"  = tncir."intCardTypeID"
		
			WHERE  
				MP."intPaymentStatus" = 2  
				AND MP."intPGRefNo" IS NOT NULL 
				AND (MP."intPaymentGatewayID" = 1)
				AND tncir."bCardReplaced" = FALSE -- REPLACE card request IS inserting IN tblNewCardIssueRequest TABLE So..
				AND MP."dteCreatedOn" > '2021-08-25 00:00:00' AND MP."dteCreatedOn" < '2021-10-08 23:59:59' 
			ORDER BY MP."dteCreatedOn" DESC --LIMIT 10
		)
		UNION ALL 
		(
			--Replace Card
			SELECT 
				MP."intMOTransactionID" AS "AppRefNo",
				MP."intTransactionAmount"/100 as "intTransactionAmount",
				CASE 
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSREC' THEN 'Top-up'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSANN' AND MP."intMOTransactionTypeID" = 5 THEN 'New Application- Anonymous'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSPER' AND MP."intMOTransactionTypeID" = 5 THEN 'New Application- Personalized'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSANN' AND MP."intMOTransactionTypeID" = 6 THEN 'Replacement- Anonymous'
					WHEN tpgscc."strServiceCode" = 'CTUBUSPASSPER' AND MP."intMOTransactionTypeID" = 6 THEN 'Replacement - Personalized'
				ELSE tpgscc."strServiceCode" END AS "ServiceCode",
				MP."dteCreatedOn"::DATE AS "Date"
			FROM 
				"tblMOPaymentDetails" MP
				
				INNER JOIN "tblReplaceCardRequest" trcr 
				ON trcr."strRequestRefNo" = MP."intMOTransactionID"::CHARACTER VARYING 
				
				INNER JOIN "tblCards" TC ON 				
				TC."intCardID" = trcr."intCardID"
				
				INNER JOIN "tblPaymentGatewayServiceCodeConfig" tpgscc
				ON tpgscc."intPaymentGatewayID" = MP."intPaymentGatewayID"
				AND tpgscc."intTransactionTypeID" = MP."intMOTransactionTypeID"
				AND tpgscc."intCardTypeID"  = TC."intSmartCardTypeID"
		
			WHERE  
				MP."intPaymentStatus" = 2  
				AND MP."intPGRefNo" IS NOT NULL 
				AND (MP."intPaymentGatewayID" = 1)
				AND MP."dteCreatedOn" > '2021-08-25 00:00:00' AND MP."dteCreatedOn" < '2021-10-08 23:59:59' 
			ORDER BY MP."dteCreatedOn" DESC --LIMIT 10
		);
