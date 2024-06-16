import gleam/dict
import gleam/dynamic
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/pair
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import tardis

pub type Msg {
  AddedInput
  UpdatedCatAtIndex(Int, String)
  UpdatedCatList(dict.Dict(Int, option.Option(String)))
}

pub type Model {
  Model(cats: dict.Dict(Int, option.Option(String)))
}

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    AddedInput -> #(
      Model(dict.insert(model.cats, dict.size(model.cats), option.None)),
      effect.none(),
    )
    UpdatedCatAtIndex(idx, newcat) -> #(
      Model(cats: dict.update(model.cats, idx, fn(_old_value) { Some(newcat) })),
      effect.none(),
    )
    UpdatedCatList(newdict) -> #(Model(cats: newdict), effect.none())
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  html.div([], [
    element.fragment(
      model.cats
      |> dict.to_list
      |> list.sort(by: fn(a, b) { int.compare(pair.first(a), pair.first(b)) })
      |> list.map(fn(a) { view_cat_input(pair.first(a), pair.second(a)) }),
    ),
    html.button([event.on_click(AddedInput)], [html.text("Add another cat")]),
  ])
}

pub fn view_cat_input(
  index: Int,
  cat: option.Option(String),
) -> element.Element(Msg) {
  let update_cat_with_index = function.curry2(UpdatedCatAtIndex)
  html.input([
    attribute.name("input-" <> int.to_string(index)),
    event.on_input(update_cat_with_index(index)),
    attribute.value(case cat {
      Some(cat) -> cat
      _ -> ""
    }),
  ])
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model(dict.from_list([#(0, Some("Puss in boots"))])), effect.none())
}

pub fn main() {
  let assert Ok(main) = tardis.single("main")

  lustre.application(init, update, view)
  |> tardis.wrap(with: main)
  |> lustre.start("#app", Nil)
  |> tardis.activate(with: main)
}
