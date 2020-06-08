/// Factory method(s) for MySiteViewController
extension BlogListViewController {
    /// returns an instance of MySiteViewController initialized with a ScenePresenter (concrete) type
    @objc func makeMySiteViewController() -> MySiteViewController {
        return MySiteViewController(meScenePresenter: makeMeScenePresenter())
    }

    func makeMeScenePresenter() -> ScenePresenter {
        return self.meScenePresenter
    }
}
