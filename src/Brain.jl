Hook(pf::AbstractPortfolio, date::Date, logger) = nothing

function SimulatePortfolioDecisionMaker(pf::AbstractPortfolio, initDate::Date, endDate::Date, logger=nothing; verbose=true)
	history = CheckLoadHistory()
	for day in WallStreetDayIterator(initDate,endDate)
		verbose ? println("$day") : nothing
		toLong = Array{Tuple{Asset,Number},1}()
		dateOpen = NextWallStreetDay(day)
		for (k,v) in history
			# Check that haven't already invested in asset in last 10 days
			openInvts = sort( OpenInvestments(pf, v.asset), by = x->x.dateOpen )
			if !isempty(openInvts) && (day - Date(openInvts[end].dateOpen)).value < 10
				continue
			end

			# Buy if confidence higher than threshold
			confidence = LongConfidence(v.asset, pf, day)
			if confidence > LongThreshold(pf)
				push!(toLong, (v.asset,confidence))
			end

			# Close if either has reached high point or too low
			for inv in openInvts
				if CloseConfidence(inv, pf, day) > CloseThreshold(pf)
					Close!(pf, inv, FetchCloseAssetValue(inv.asset,day), EndOf(day))
				end
			end
		end

		sort!(toLong, by = x->x[2], rev=true)
		for (asset, confidence) in toLong
			# Check if there are still spots to invest
			if size(OpenInvestments(pf),1) > MaxNumberOfInvestment(pf)
				break
			end

			# Long position
			openValue = FetchOpenAssetValue(asset, dateOpen)
			Long!(pf, asset, openValue, 100, dateOpen = dateOpen)
		end

		# Hook in process
		Hook(pf, day, logger)
	end
end
