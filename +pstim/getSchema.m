function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'pstim', 'pstim');
end
obj = schemaObject;
