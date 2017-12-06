function [formulaList, rxnsList, absentRxns, duplicatedRxns] = mapFormula(map, rxnList) 
% Prints reactions formulas from a CellDesigner XML map file
%
% USAGE:
%
%   [formulaList, rxnsList, absentRxns, duplicatedRxns] = mapFormula(map, rxnList)
%
% INPUTS:
%   map:            A parsed model structure generated by 
%                   "transformXML2MatStruct" function
%   rxnList:        List of reactions which formulas will to be printed
%
% OUTPUTS:
%   formulaList:        List of formulas
%   rxnsList:           Present reactions from the list (rxnList) in the map
%   absentRxns:         Reactions in the map not in the model
%   duplicatedRxns:     Duplicated reactions in the map
%
% .. Authors:
%       - N.Sompairac - Institut Curie, Paris, 15/07/2017.
%       - A.Danielsdottir  Belval, Luxembourg, 15/07/2017.
%       - J.Modamio. LCSB, Belval, Luxembourg, 23/07/2017. (identify repeated rxns in the map)

    % Check what reactions are present in the list but not in the map
    absentRxns = setdiff(rxnList,map.rxnName);

    if ~isempty(absentRxns)
        disp(sprintf('Attention : %d reaction(s) not present in the map!!!', length(absentRxns)))
    end

    % Get the list of only the present reactions in both the list and map
    PresentRxns = intersect(rxnList, map.rxnName);

    % List containing the duplicated reactions names
    duplicatedRxns = {};
    
    i = 1;
    for a = PresentRxns'
        R = strcmp(map.rxnName(:,1),a);
        rxnIndex_list=find(R);
        for rxnIndex = rxnIndex_list'
            left = {};
            % Base reactant
            basereact = map.rxnBaseReactantID{rxnIndex};
            basereact = map.specName(ismember(map.specID,basereact));
            left = [left; basereact];
            
            % Secondary reactants 
            for reactant = 1:length(map.rxnReactantID{rxnIndex})
                reac = map.rxnReactantID{rxnIndex}{reactant};
                reac = map.specName(ismember(map.specID,reac));
                left = [left; reac];
            end

            right = {};
            % Base product
            baseprod = map.rxnBaseProductID{rxnIndex};
            baseprod = map.specName(ismember(map.specID,baseprod));
            right = [right; baseprod];

            % Secondary products
            for product = 1:length(map.rxnProductID{rxnIndex})
                prod = map.rxnProductID{rxnIndex}{product};
                prod = map.specName(ismember(map.specID,prod));
                right = [right; prod];
            end

            formula = sprintf('%s',left{1});

            for x = 2:length(left) % add (+) in reactant list
                formula = sprintf('%s + %s',formula,left{x});
            end

            if strcmp(map.rxnReversibility{rxnIndex}, 'true') %add directionality of the reaction
                formula = sprintf('%s <=> ',formula); %reversible (true) 
            else
                formula = sprintf('%s -> ',formula); %irreversible (false)
            end

            formula = sprintf('%s%s',formula,right{1});

            for x = 2:length(right) % add (+) in product list
                formula = sprintf('%s + %s',formula,right{x});
            end
            
            rxnsList(i,1) = a;
            formulaList(i,1) = {formula}; %create a sumary of rxnsName and formula
            i = i+1;
        end
        
        % Check if the reaction name if actually a duplicate
        if length(rxnIndex_list) > 1
            duplicatedRxns = [duplicatedRxns, a];
        end
    end 

end
