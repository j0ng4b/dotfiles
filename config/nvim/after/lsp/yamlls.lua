local ok, schemastore = pcall(require, "schemastore")
if not ok then
    return {}
end

return {
    settings = {
        yaml = {
            schemas = schemastore.yaml.schemas(),

            -- schemastore.nvim replaces the built-in schema store.
            schemaStore = {
                enable = false,
                url = "",
            },
        },
    },
}

