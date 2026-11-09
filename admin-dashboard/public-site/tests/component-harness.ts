import { readFileSync } from "node:fs";
import vm from "node:vm";
import ts from "typescript";

export type TestElement = { type: unknown; props: Record<string, any> };

// Execute component handlers without a browser or network. State survives rerenders;
// effects are explicit so tests can inspect the HTML contract before hydration.
export function createComponentHarness(file: URL, dependencies: Record<string, unknown>, globals: Record<string, unknown> = {}) {
  const slots: unknown[] = [];
  const effects: Array<() => unknown> = [];
  let cursor = 0;
  const hooks = {
    useState(initial: unknown) {
      const index = cursor++;
      if (!(index in slots)) slots[index] = typeof initial === "function" ? initial() : initial;
      return [slots[index], (value: unknown) => { slots[index] = typeof value === "function" ? value(slots[index]) : value; }];
    },
    useRef(initial: unknown) {
      const index = cursor++;
      if (!(index in slots)) slots[index] = { current: initial };
      return slots[index];
    },
    useMemo(factory: () => unknown) { return factory(); },
    useEffect(effect: () => unknown, dependencies?: unknown[]) {
      const index = cursor++;
      const previous = slots[index] as unknown[] | undefined;
      if (!previous || !dependencies || dependencies.some((value, i) => value !== previous[i])) effects.push(effect);
      slots[index] = dependencies ?? [];
    }
  };
  const jsx = (type: unknown, props: Record<string, unknown>) => ({ type, props });
  const module = { exports: {} as Record<string, (...args: any[]) => TestElement> };
  const output = ts.transpileModule(readFileSync(file, "utf8"), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, jsx: ts.JsxEmit.ReactJSX, esModuleInterop: true }
  });
  vm.runInNewContext(output.outputText, {
    module, exports: module.exports, URL, URLSearchParams,
    require(name: string) {
      if (name === "react") return hooks;
      if (name === "react/jsx-runtime") return { jsx, jsxs: jsx, Fragment: Symbol.for("test.fragment") };
      if (Object.hasOwn(dependencies, name)) return dependencies[name];
      throw new Error(`Unmocked component import: ${name}`);
    },
    ...globals
  }, { filename: file.pathname });
  return {
    render(exportName: string, props: Record<string, unknown> = {}) {
      cursor = 0;
      return module.exports[exportName](props);
    },
    flushEffects() { while (effects.length) effects.shift()?.(); }
  };
}

export function elements(tree: unknown): TestElement[] {
  if (Array.isArray(tree)) return tree.flatMap(elements);
  if (!tree || typeof tree !== "object" || !("type" in tree) || !("props" in tree)) return [];
  const element = tree as TestElement;
  if (typeof element.type === "function") return elements(element.type(element.props));
  return [element, ...elements(element.props.children)];
}

export function findElement(tree: unknown, predicate: (element: TestElement) => boolean): TestElement {
  const found = elements(tree).find(predicate);
  if (!found) throw new Error("Expected component element was not rendered.");
  return found;
}
