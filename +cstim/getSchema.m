function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cstim', 'cstim');
end
obj = schemaObject;
