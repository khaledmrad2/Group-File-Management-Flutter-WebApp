<?php /** @noinspection PhpUndefinedMethodInspection */

namespace App\Http\Controllers\File;

use App\Http\Controllers\Controller;
use App\Http\Requests\UploadFileRequest;
use App\Models\File;
use App\Oper\FileOper;
use App\Oper\FileReports;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use JetBrains\PhpStorm\Pure;

class FileController extends Controller
{
    private FileReports $report;
    private FileOper $oper;

    #[Pure] public function __construct()
    {
        $this->report = new FileReports();
        $this->oper = new FileOper();
    }

    public function uploadFileUser(UploadFileRequest $request): JsonResponse
    {
        $file = File::query()->create([
            'user_id' => Auth::id(),
            'status' => 1,
            'version'=>1
        ]);
        $this->oper->saveFile($request, $file);
        $this->report->saveAddFileReportUser($file);
        return response()->json([
            'status' => true,
            'data' => $file
        ]);
    }

    public function deleteFile($id): JsonResponse
    {
        $file = File::query()->where('status', 1)->find($id);
        if (!$file)
            return response()->json([
                'status' => false,
                'message' => 'Can\'t delete file because it is in use'
            ], 400);
        $file->clearMediaCollection();
        $file->delete();
        return response()->json([
            'message' => 'File deleted successfully'
        ]);
    }
}

/*
 *     public function uploadFileAdmin(UploadFileRequest $request): JsonResponse
    {
        $file = File::query()->create([
            'admin_id' => Auth::id(),
            'status' => 1
        ]);
        $this->saveFile($request, $file);
        $this->report->saveAddFileReportAdmin($file);
        return response()->json([
            'status' => true,
            'data' => $file
        ]);
    }

 */
