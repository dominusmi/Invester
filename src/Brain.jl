function SimulatePortfolioDecisionMaker(pf::AbstractPortfolio, initDate::Date, endDate::Date, threshold = 0.5)
	history = CheckLoadHistory()
	for day in DayOfWeekIterator(initDate,endDate)
		for (k,v) in history
			# TODO: check that don't already have Investment recently
			openInvts = sort( OpenInvestments(pf, v.asset), by = x->x.dateOpen )
			if (day - openInvts[end]).value < 10
				continue
			end

			if LongConfidence(v.asset, pf, day) > threshold
				dateOpen = day + Day(1)
				open = FetchOpenAssetValue(v.asset, dateOpen)
				Long!(pf, asset, open, dateOpen = dateOpen)
			end
			# TODO: check which investments to close
		end
	end
end
