function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'ltpdaloc', 'ltpdaloc');
end
obj = schemaObject;
