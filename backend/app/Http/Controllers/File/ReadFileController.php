<?php /** @noinspection PhpUndefinedFieldInspection */

namespace App\Http\Controllers\File;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\File;
use App\Models\FileGroup;
use App\Models\Report;
use App\Models\User;
use App\Oper\FileOper;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use JetBrains\PhpStorm\Pure;

class ReadFileController extends Controller
{
    private FileOper $oper;

    #[Pure] public function __construct()
    {
        $this->oper = new FileOper();
    }


    public function readFile($id): JsonResponse
    {
        $file = File::query()->with('media')->findOrFail($id);
        if (!($file->status))
            $file['blocking_user'] = $this->oper->getBlockingUser($file->id);
        else
            $file['blocking_user'] = '';
        return response()->json([
            'message' => 'success',
            'file' => $file
        ]);
    }

    public function userFiles(): JsonResponse
    {
        $files = File::where('user_id', Auth::id())->with('media')->get();
        return response()->json([
            'message' => 'success',
            'files' => $files
        ]);
    }

    public function groupFiles($id): JsonResponse
    {
        $filesIds = FileGroup::query()->where('group_id', $id)
            ->get(['file_id']);
        $files = File::query()->whereIn('id', $filesIds)->with('media')
            ->get();
        foreach ($files as $file) {
            if (!($file->status)) {
                $file['blocking_user_id'] = $this->oper->getBlockingUser($file->id)->id;
                $file['blocking_user_name'] = $this->oper->getBlockingUser($file->id)->name;
            } else {
                $file['blocking_user_id'] = null;
                $file['blocking_user_name'] = null;
            }
        }
        return response()->json([
            'message' => 'success',
            'files' => $files
        ]);
    }

}

/*
 * public function adminFiles(): JsonResponse
    {
        $files = File::where('admin_id', Auth::id())->with('media')->get();
        return response()->json([
            'message' => 'success',
            'files' => $files
        ]);
    }
 */
