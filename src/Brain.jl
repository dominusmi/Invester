function SimulatePortfolioDecisionMaker(pf::AbstractPortfolio, initDate::Date, endDate::Date, threshold = 0.5)
	history = CheckLoadHistory()
	for day in DayOfWeekIterator(initDate,endDate)
		@show day
		for (k,v) in history
			@show v.asset
			# Check that haven't already invested in asset in last 10 days
			openInvts = sort( OpenInvestments(pf, v.asset), by = x->x.dateOpen )
			if !isempty(openInvts) && (day - Date(openInvts[end].dateOpen)).value < 10
				continue
			end

			# Buy if confidence higher than threshold
			if LongConfidence(v.asset, pf, day) > threshold
				dateOpen = day + Day(1)
				open = FetchOpenAssetValue(v.asset, dateOpen)
				Long!(pf, v.asset, open, dateOpen = dateOpen)
			end

			# Close if either has reached high point or too low
			for inv in openInvts
				if CloseConfidence(inv, pf, day) > threshold
					Close!(pf, investment, currentValue, date)
				end
			end
		end
	end
end
