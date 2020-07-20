/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace Facebook\XHP\Core;

use namespace HH\Lib\Dict;

/**
 * :x:primitive lays down the foundation for very low-level elements. You
 * should directly :x:primitive only if you are creating a core element that
 * needs to directly implement stringify(). All other elements should subclass
 * from :x:element.
 */
abstract xhp class primitive extends node {
  abstract protected function stringifyAsync(): Awaitable<string>;

  <<__Override>>
  final public async function toStringAsync(): Awaitable<string> {
    invariant(!$this->__isRendered, 'Attempted to render XHP element twice');
    $that = await $this->__flushSubtree();
    $result = await $that->stringifyAsync();
    $this->__isRendered = true;
    return $result;
  }

  final private async function __flushElementChildren(): Awaitable<void> {
    $children = $this->getChildren();
    $awaitables = dict[];
    foreach ($children as $idx => $child) {
      if ($child is node) {
        $child->__transferContext($this->getAllContexts());
        $awaitables[$idx] = $child->__flushSubtree();
      }
    }
    if ($awaitables) {
      $awaited = await Dict\from_async($awaitables);
      foreach ($awaited as $idx => $child) {
        $children[$idx] = $child;
      }
    }
    $this->replaceChildren($children);
  }

  <<__Override>>
  final protected async function __flushSubtree(): Awaitable<primitive> {
    await $this->__flushElementChildren();
    if (\Facebook\XHP\ChildValidation\is_enabled()) {
      $this->validateChildren();
    }
    return $this;
  }
}
