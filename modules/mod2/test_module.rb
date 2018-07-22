class TestModule2 < WebcoreApp()
    get "/?" do
        "I am #{webcore_module.id}"
    end
end