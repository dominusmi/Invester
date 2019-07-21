function SimulatePortfolioDecisionMaker(pf::AbstractPortfolio, initDate::Date, endDate::Date)
	history = CheckLoadHistory()
	for day in WallStreetDayIterator(initDate,endDate)
		@show day
		for (k,v) in history
			# Check that haven't already invested in asset in last 10 days
			openInvts = sort( OpenInvestments(pf, v.asset), by = x->x.dateOpen )
			if !isempty(openInvts) && (day - Date(openInvts[end].dateOpen)).value < 10
				continue
			end

			if size(OpenInvestments(pf),1) < MaxNumberOfInvestment(pf)
				# Buy if confidence higher than threshold
				if LongConfidence(v.asset, pf, day) > LongThreshold(pf)
					dateOpen = NextWallStreetDay(day)
					open = FetchOpenAssetValue(v.asset, dateOpen)
					Long!(pf, v.asset, open, 100, dateOpen = dateOpen)
				end
			end

			# Close if either has reached high point or too low
			for inv in openInvts
				if CloseConfidence(inv, pf, day) > CloseThreshold(pf)
					Close!(pf, inv, FetchCloseAssetValue(inv.asset,day), EndOf(day))
				end
			end
		end
	end
end