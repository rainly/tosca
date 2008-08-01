atom_feed do |feed|
  feed.title(_('Contributions of 08000linux.com'))
  feed.link("http://" + request.host_with_port + request.request_uri)
  feed.updated(@contributions.first.updated_on)
  for contribution in @contributions
    options = { :published => contribution.created_on,
                :updated => contribution.updated_on }
    feed.entry(contribution, options) do |entry|
      entry.title("[#{contribution.logiciel.name}] #{contribution.synthesis}")
      entry.content(contribution.description_fonctionnelle, :type => 'html')
      entry.author do |author|
        author.name(contribution.ingenieur.name)
      end
    end
  end
end
