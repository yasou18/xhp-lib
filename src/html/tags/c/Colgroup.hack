/*
 *  Copyright (c) 2004-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace Facebook\XHP\HTML;

use namespace Facebook\XHP\ChildValidation as XHPChild;

final xhp class colgroup extends element {
  use XHPChild\Validation;
  attribute int span;

  protected static function getChildrenDeclaration(): XHPChild\Constraint {
    return XHPChild\any_number_of(XHPChild\of_type<col>());
  }

  protected string $tagName = 'colgroup';
}
