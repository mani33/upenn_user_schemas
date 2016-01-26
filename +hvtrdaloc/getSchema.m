function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'hvtrdaloc', 'hvtrdaloc');
end
obj = schemaObject;
