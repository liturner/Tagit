TagitListviewMixin = {}

function TagitListviewMixin:OnLoad()
    self.scrollView = CreateScrollBoxListLinearView();

    ---height is defined in the xml keyValues
    local height = self.elementHeight;
    self.scrollView:SetElementExtent(height);
    self.scrollView:SetElementInitializer("UIPanelButtonTemplate", GenerateClosure(self.OnElementInitialize, self));
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    --self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollView);

    self.scrollView:SetPadding(1, 1, 1, 1, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -1, 1),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.scrollBox, self.scrollBar, anchorsWithBar, anchorsWithoutBar);
end

function TagitListviewMixin:OnElementInitialize(element, elementData, isNew)
    print("element: "..tostring(element))
    print("elementData: "..tostring(elementData))
    print("isNew: "..tostring(isNew))
    if isNew then
        element:OnLoad();
    end
    element:SetText(elementData.Label)
end

function TagitListviewMixin:OnElementReset(element)
    --element:ResetDataBinding()
end

function TagitListviewMixin:GetDataProvider()
    return self.scrollView:GetDataProvider();
end

function TagitListviewMixin:SetDataProvider(dataProvider)
    self.scrollView:SetDataProvider(dataProvider);
end
