import assert from "node:assert/strict";
import test from "node:test";
import { coverageCityOptions } from "../src/lib/map/city-options.ts";
import { filterCoverageMapItems, type CoverageMapItem } from "../src/lib/map/coverage.ts";
const place = (cityId: string, title: string, type: CoverageMapItem["type"] = "place"): CoverageMapItem => ({id: title, title, cityId, type, provinceId: null, summary: "", route: "/", coordinate: {latitude: 52, longitude: 5}, categorySlugs: ["hotel"], verifiedAt: "2026-11-03", sourcePublisher: "test"});
test("places-only map uses city names, never the first venue title", () => {
  assert.deepEqual(coverageCityOptions([place("rotterdam", "Supernova Hotel"),place("utrecht", "Park Oog in Al")]),[{id:"rotterdam",label:"Rotterdam"},{id:"utrecht",label:"Utrecht"}]);
});
test("city labels win over municipality and venue labels regardless of order", () => {
  const items=[place("rotterdam","Supernova"),place("rotterdam","Gemeente Rotterdam","municipality"),place("rotterdam","Rotterdam","city")];
  assert.deepEqual(coverageCityOptions(items),coverageCityOptions([...items].reverse()));
  assert.equal(coverageCityOptions(items)[0].label,"Rotterdam");
});
test("The Hague aliases retain original IDs for filtering", () => {
  for(const id of ["den-haag","s-gravenhage"]) {
    const items=[place(id,"Kaafi")];
    assert.deepEqual(coverageCityOptions(items),[{id,label:"Den Haag"}]);
    assert.equal(filterCoverageMapItems(items,{city:id,province:"all",category:"all",type:"all",query:""}).length,1);
  }
});
test("unknown city slug has a readable fallback, empty input has no invented cities",()=>{
 assert.deepEqual(coverageCityOptions([place("nieuwe-stad","Cafe name")]),[{id:"nieuwe-stad",label:"Nieuwe Stad"}]);
 assert.deepEqual(coverageCityOptions([]),[]);
 assert.deepEqual(coverageCityOptions([{...place("utrecht","X"),cityId:null}]),[]);
});
