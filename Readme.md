### Ideas to develop

**Genetic Algorithm**
- Genes would be basic building blocks
- Tree like evolving structure
- Features would be learnt by the model
- Helper functions provided (e.g. moving average over n-days)

**Convolutional Neural Network**
- Transform univariate data
- Learn classification into high sets:
  - +5%, 2.5-5%, 1-2.5%, ..

**Find if there's seasonality in week**
- Are days identical or not?
- Would be interesting even to implement in CNN

### TODO
- SimulatePortfolioDecisionMaker needs to be tested further
- add check for asset which do not have enough history

- ClosedInvestment type, dateOpen and dateClosed different convention (present/past tense) FIX

- upperClosePercentageThreshold and lowerClosePercentageThreshold are not actually used in simulation

- Need to create file to fetch updated information and merge CSVs


### API
API used are IEXTradingAPI and AlphadvantageAPI, although the latter more so.
The limits for AA are 5 requests per minute and 500 per day.
