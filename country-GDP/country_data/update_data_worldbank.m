% update country data

clear all

% load list of countries
parent_dir = pwd;
if IsWin 
    list_countries = load([parent_dir '\list_countries_complete.mat']);
else
    list_countries = load([parent_dir '/list_countries_complete.mat']);
end

% World Bank API endpoint for country list
url = 'http://api.worldbank.org/v2/country?format=json&per_page=300';

% Fetch the country list
data = webread(url);

% Extract the country names and codes
countriesData = data{2};
countryNames = {countriesData.name};
countryCodes = {countriesData.id};

% Create a table or a map for the country names and codes
countryMapping = containers.Map(countryNames, countryCodes);

% Assuming countryMapping is a Map object with country names as keys and World Bank codes as values

% % World Bank API endpoint for GDP per capita (current US$)
% urlFormat = 'http://api.worldbank.org/v2/country/%s/indicator/NY.GDP.PCAP.CD?date=2020&format=json';

% World Bank API endpoint for GDP per capita (current US$) with MRV
% MRV means most recent value
urlFormat = 'http://api.worldbank.org/v2/country/%s/indicator/NY.GDP.PCAP.CD?format=json&MRV=1';


for i = 1:length(list_countries.wordLists)
    % Extract country name
    countryName = list_countries.wordLists{i, 1};

    % Check if the country name is in the mapping
    if isKey(countryMapping, countryName)
        % Get the World Bank country code from the mapping
        countryCode = countryMapping(countryName);

        % Fetch the GDP data from the World Bank API
        url = sprintf(urlFormat, countryCode);
        data = webread(url);

        % Extract the GDP value from the fetched data
        % Note: Add error handling here to deal with cases where data is not found.
        if ~isempty(data) && ~isempty(data{2})
            gdpValue = data{2}(1).value;
        else
            gdpValue = NaN; % Use NaN for countries where data is not available
        end

        % Update the numList field in the structure
        list_countries.numList(i) = gdpValue;
    else
        % If country is not found in the mapping, handle accordingly (e.g., set to NaN)
        list_countries.numList(i) = NaN;
    end
end

% last update done on 23 Nov 2023
save('list_countries_complete_updated.mat','-struct','list_countries');


% % sanity checks
% L1 = load([parent_dir '/list_countries_complete.mat']);
% L2 = load([parent_dir '/list_countries_complete_updated.mat']);



