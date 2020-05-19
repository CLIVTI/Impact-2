function CopySupply=CopySupply(Supply)
% create another instance of Supply structure
CopySupply={};
ModeAlternatives=fieldnames(Supply);
for i=1:length(ModeAlternatives)
  if  isa(Supply.(ModeAlternatives{i}),'containers.Map')
      CopySupply.(ModeAlternatives{i})=containers.Map();
      VarNames_alternative_i=keys(Supply.(ModeAlternatives{i}));
      for j=1:length(VarNames_alternative_i)
          ParameterValuePair=Supply.(ModeAlternatives{i})(VarNames_alternative_i{j});
          CopySupply.(ModeAlternatives{i})(VarNames_alternative_i{j})=ParameterValuePair;
      end
  elseif isa(Supply.(ModeAlternatives{i}),'struct')
      NestedAlternatives=fieldnames(Supply.(ModeAlternatives{i}));
      for k=1:length(NestedAlternatives)
          CopySupply.(ModeAlternatives{i}).(NestedAlternatives{k})=containers.Map();
          VarNames_alternative_i_j=keys(Supply.(ModeAlternatives{i}).(NestedAlternatives{k}));
          for j=1:length(VarNames_alternative_i_j)
              ParameterValuePair=Supply.(ModeAlternatives{i}).(NestedAlternatives{k})(VarNames_alternative_i_j{j});
              CopySupply.(ModeAlternatives{i}).(NestedAlternatives{k})(VarNames_alternative_i_j{j})=ParameterValuePair;
          end
      end
  end
    
end

return