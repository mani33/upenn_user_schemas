function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'ltp', 'ltp');
end
obj = schemaObject;
