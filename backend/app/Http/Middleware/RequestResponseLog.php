<?php

namespace App\Http\Middleware;

use App\Models\Log as LogModel;
use Closure;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;

class RequestResponseLog
{
    /**
     * Handle an incoming request.
     *
     * @param Request $request
     * @param Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return Response|RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        DB::beginTransaction();

        $response = $next($request);

        $log = new LogModel();
        $log->RequestURI = json_encode($request->getURI());
        $log->RequestMethod = json_encode($request->getMethod());
        $log->RequestBody = json_encode($request->all());
        $log->Response = json_encode($response->getContent());
        $log->save();

        if ($response->status() != 200 && $response->status() != 201) {
            DB::rollBack();
        } else {
            DB::commit();
        }

        return $response;
    }
}
