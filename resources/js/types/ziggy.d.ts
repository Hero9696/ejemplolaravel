import { Config, RouteName, Params, Route } from 'ziggy-js';

// Declara la función global 'route' usando los tipos importados
declare global {
    function route(
        name: RouteName,
        params?: Params | Route,
        absolute?: boolean,
        config?: Config
    ): Route;
}
