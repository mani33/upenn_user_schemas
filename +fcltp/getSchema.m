function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'fcltp', 'fcltp');
end
obj = schemaObject;
