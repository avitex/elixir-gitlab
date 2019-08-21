defmodule Gitlab.Endpoint do
  @type t :: module()

  @type url :: String.t()
  @type id :: integer() | String.t()
  @type scope :: resource() | resource_list()

  @type resource :: resource_simple | resource_scoped
  @type resource_simple :: {t(), id()}
  @type resource_scoped :: {t(), scope(), id()}

  @type resource_list :: resource_list_simple | resource_list_scoped
  @type resource_list_simple :: t()
  @type resource_list_scoped :: {t(), scope()}

  @callback endpoint_name() :: String.t()
  # @callback endpoint_has_parent?(scope()) :: boolean()

  @spec url(resource_scoped()) :: url()
  def url({endpoint, scope_parent, internal_id}) do
    join_pair(url({endpoint, scope_parent}), internal_id)
  end

  @spec url(resource_list_scoped()) :: url()
  def url({endpoint, scope_parent}) when is_atom(scope_parent) or is_tuple(scope_parent) do
    join_pair(url(scope_parent), url(endpoint))
  end

  @spec url(resource_simple()) :: url()
  def url({endpoint, global_id}) do
    join_pair(url(endpoint), global_id)
  end

  @spec url(resource_list_simple()) :: url()
  def url(endpoint) when is_atom(endpoint) do
    endpoint.endpoint_name()
  end

  @spec url(resource_simple(), scope() | nil) :: url()
  def url({endpoint, id}, parent_scope) do
    if is_nil(parent_scope) do
      url({endpoint, id})
    else
      url({endpoint, parent_scope, id})
    end
  end

  @spec url(resource_list_simple(), scope()) :: url()
  def url(endpoint, parent_scope) when is_atom(endpoint) do
    if is_nil(parent_scope) do
      url(endpoint)
    else
      url({endpoint, parent_scope})
    end
  end

  defp join_pair(left, right) do
    "#{left}/#{right}"
  end
end
