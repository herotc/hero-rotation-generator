# -*- coding=utf-8 -*-
"""
decoratormanager
DecoratorManager class to register decorators to specific classes.
Created by Romain Mondon-Cancel on 2018-05-24 15:36:36
"""


class DecoratingManager(object):
    _decorators = []

    def register(self, class_name, method, decorator):
        self._decorators += [(class_name, method, decorator)]

    def remove(self, class_name, method, decorator):
        self._decorators.remove((class_name, method, decorator))

    def decorator(dm, cls):
        class Wrapper(cls):
            def __getattribute__(self, name):
                decorator_stack = []
                for class_name, method, decorator in dm._decorators:
                    if name == method and self.__class__.__name__ == class_name:
                        decorator_stack += [decorator]
                if not decorator_stack:
                    return object.__getattribute__(self, name)
                try:
                    assert hasattr(self.__class__, name)
                    result = getattr(self.__class__, name)
                except AssertionError:
                    result = (lambda *args: None)
                for decorator in decorator_stack:
                    result = decorator(result)
                return result.__get__(self)

        return Wrapper


decorating_manager = DecoratingManager()


@decorating_manager.decorator
class Decorable(object):
    pass
