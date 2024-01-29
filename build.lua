os.execute(
    string.format(
        'go build -C %s/lazy/nvim-texlabconfig',
        vim.fn.stdpath("data")
    )
)
